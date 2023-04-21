import pandas as pd
import numpy as np
import re

# az adatkapcsolat létrehozása
from sqlalchemy import create_engine


# forrás: https://stackoverflow.com/questions/72985415/python-sql-query-parameterized


def adatolvasas(table_name):
    engine = create_engine('mysql+pymysql://laci:minimano@10.8.16.6:4619/eoptika_analytics')
    con = engine.connect()
    
    ds = con.execute(''' SELECT * FROM {} '''.format(table_name))
    table_name = pd.DataFrame(ds.fetchall())
    table_name.columns = ds.keys()
    
    # adatkapcsolat bezárása
    con.close()
    
    return(table_name)



####  ADATTÁBLA BEOLVASÁSOK ###
INVOICES_00 = adatolvasas('outgoing_bills')
IN_net_purchase_price_correction = adatolvasas('IN_net_purchase_price_correction')
erp_purchase_prices = adatolvasas('erp_purchase_prices')
IN_exchange_rate_correction = adatolvasas('IN_exchange_rate_correction')
IN_email_correction = adatolvasas('IN_email_correction')
IN_test_users = adatolvasas('IN_test_users')
IN_user_type = adatolvasas('IN_user_type')
IN_country_coding = adatolvasas('IN_country_coding')
IN_city_coding = adatolvasas('IN_city_coding')


####  IN_country_coding egyedivé tétele shipping_country-ra ###

IN_country_coding = IN_country_coding.drop(columns='language')
IN_country_coding_unique = IN_country_coding.drop_duplicates(subset='original_country')


####  error correction ###
# 1. egyedi hibás értékek kijavítása
INVOICES_00.loc[INVOICES_00['related_webshop'] == "LenteContatto.it", 'related_division'] = "Optika - IT"
INVOICES_00.loc[INVOICES_00['related_webshop'] == "netOptica.ro", 'related_division'] = "Optika - RO"
INVOICES_00.loc[INVOICES_00['item_sku'] == "AO_MIRR", 'item_sku'] = "AOA_MIRR"
INVOICES_00.loc[(INVOICES_00['shipping_method'] == "GPSe") & (INVOICES_00['shipping_country'] == "HUN"), 'shipping_method'] = "Pickup in person"
INVOICES_00.loc[(INVOICES_00['shipping_method'] == "Személyes átvétel") & (INVOICES_00['shipping_country'] == "ITA"), 'shipping_method'] = "GLS"
INVOICES_00.loc[INVOICES_00['shipping_method'] == "Személyes átvétel", 'shipping_method'] = "Pickup in person"
INVOICES_00.loc[INVOICES_00['related_division'] == "Optika - HU", 'related_division'] = "Egyebek in person"
INVOICES_00.loc[INVOICES_00['related_email'] == "petranagy19@gmail.com", 'shipping_name'] = "Nagy Petra"
INVOICES_00.loc[INVOICES_00['related_email'] == "petranagy19@gmail.com", 'billing_name'] = "Nagy Petra"
INVOICES_00.loc[INVOICES_00['related_email'] == "szeghalmi.kati@yahoo.com",  'shipping_name'] = "Szeghalmi Katalin"

INVOICES_00.loc[INVOICES_00['related_webshop'] == "netOptica.ro", 'related_division'].unique()



# 2. az "item_net_purchase_price_in_base_currency" mező értékeinek a felülírása az "erp_purchase_prices"  táblából
merged_df = INVOICES_00.merge(erp_purchase_prices, left_on=['erp_id', 'item_sku'], right_on=['invoice_reference', 'sku'], how='inner')
INVOICES_00['item_net_purchase_price_in_base_currency'] = merged_df["purchase_price"]

# 3. az "exchange_rate_of_currency" mező hibás értékeinek a felülírása az "IN_exchange_rate_correction"  táblából
merged_df = INVOICES_00.merge(IN_exchange_rate_correction, left_on=['erp_id'], right_on=['erp_id'], how='left')
INVOICES_00['exchange_rate_of_currency'] = merged_df['exchange_rate_of_currency_x'].fillna(merged_df['exchange_rate_of_currency_x'])

# 4. az "related_email" mező hibás értékeinek a felülírása az "IN_email_correction"  táblából
INVOICES_00['related_email'] = INVOICES_00['related_email'].map(IN_email_correction.set_index('old_email')['new_email']).fillna(INVOICES_00['related_email'])

INVOICES_00['related_email'] .tail()



# felesleges mezők eldobása
drop_list = ['our_bank_account_number',
'item_net_registered_price_in_base_currency',
'item_net_clearing_price_in_base_currency',
'item_net_sale_price_in_currency',
'item_gross_sale_price_in_currency',
'item_vat_value',
'item_gross_value',
'unit_of_quantity_eng']

INVOICES_00 = INVOICES_00.drop(drop_list , axis=1)


####  új mezők létrehozása  ###

# 1. elsőséget élvez a IN_user_type bekódoló tábla, mert az optikus minden vásárlása optikus vásárlás

# Create a new 'buyer_email' column with the values from the 'related_email' column
INVOICES_00['buyer_email'] = INVOICES_00['related_email']
merged_df = INVOICES_00.merge(IN_user_type, left_on='buyer_email', right_on='email', how='left')
merged_df['user_type'] = merged_df['user_type'].apply(lambda x: x if x in ['B2B2C Optician', 'B2B2C Pharmacist', 'B2B2B2C Wholesaler', 'B2B2C', 'B2C', 'B2B'] else 'B2C')
# item_user_type mező létrehozása
INVOICES_00['item_user_type'] = merged_df['user_type']


#  2. az item_user_type mező értékeinek felülírása a vevő által megadott shipping_name alapján
patterns = {
    r'\b(optic|optik[aá]|ottic|látszerész)\b': 'B2B2C Optician',
    r'bt\.? | bt | kft | zrt | nyrt | kkt | takarékszövetkezet|iroda|EV|egyéni vállalkozó | múzeum | egyház | misszió | központ | iskola | egyetem | óvoda | nébih | egyesület | alapítvány | foundation | association | ltd\.? | ltda | plc\.? | fiók | limited | s\.r\.l\. | s\.r\.o\. | s\.p\.a\. | s\.n\.c\. | s\.a\.s\.': 'B2B'
    
}    


for pattern, category in patterns.items():
    mask = INVOICES_00['shipping_name'].str.strip().str.contains(pattern, flags=re.IGNORECASE)
    INVOICES_00.loc[(mask) & (INVOICES_00['item_user_type'] == 'B2C'), 'item_user_type'] = category


INVOICES_00[['shipping_name','item_user_type']]



print(INVOICES_00.groupby("item_user_type").count())







IN_user_type[IN_user_type['email'] == "szalanczi.csalad@gmail.com"]
INVOICES_00[INVOICES_00['erp_id'] == "SO11/01031"].item_user_type
INVOICES_00[INVOICES_00['shipping_name'] == "Margoptik Kft"].related_email
INVOICES_00.loc[merged_df['user_type'] != 'B2C', 'item_user_type'] = merged_df['user_type']
INVOICES_00.loc[INVOICES_00['related_email'].isin(['margoptikreka@gmail.com', 'szalanczi.csalad@gmail.com'])]
INVOICES_00[INVOICES_00['erp_id'] == "SO23/H031688"].item_user_type
INVOICES_00[INVOICES_00['item_user_type'] == "B2B2C Optician"].head()








# Define the regex patterns and their corresponding categories
patterns = {
    r'@freeemail\.hu': '@freemail.hu',
    r'@(gmai|gmal|gamil|gnail|gmaikl|g-mail|g.mail|gail|gmsil|gmali|gmil|gmai|)\.com': '@gmail.com',
    r'@(gmai|gmal|gamil|gnail|gmaikl|g-mail|g.mail|gail|gmsil|gmali|gmil|gmai|)\.hu': '@gmail.hu',    
    r'@cirtomail\.com': '@citromail.com',
    r'undefined': '',
    r'#': ''
}

# Loop through each regex pattern and update the 'buyer_email' column for the matching rows
for pattern, category in patterns.items():
    mask = INVOICES_00['buyer_email'].str.contains(pattern, flags=re.IGNORECASE)
    INVOICES_00.loc[mask, 'buyer_email'] = INVOICES_00.loc[mask, 'buyer_email'].str.replace(pattern, category, regex=True)



####  szűrések ###
# removing cancelled items
INVOICES_00 = INVOICES_00.loc[INVOICES_00['is_canceled'].str.lower().isin(['no', 'élő'])]

# removing NON-CORE: szállítási díjak, marketing campaigns
INVOICES_00 = INVOICES_00.query('item_sku not in ["GHW", "MCO", "MCONS", "MDISPLAY", "GROWWW", "szallitas", "Személyes átvétel"]')

# removing test users
distinct_related_emails = IN_test_users['related_email'].unique()
INVOICES_00 = INVOICES_00[~INVOICES_00['related_email'].isin(distinct_related_emails)]

distinct_related_emails = IN_test_users['billing_name'].unique()
INVOICES_00 = INVOICES_00[~INVOICES_00['billing_name'].isin(distinct_related_emails)]

# removing előleg számlák
eloleg = INVOICES_00['item_name_hun'] == 'Előleg'
INVOICES_00 = INVOICES_00.loc[~eloleg]


INVOICES_00.count()


1.
mysql = 3.548.446
python = 3.548.448

2. élő
mysql = 3.307.178
python = 3.307.178

3. nem non-core
mysql = 3.307.135
python = 3.307.135

4. nem teszt
mysql = 3.304.871
python = 3.304.914

5.nem előleg számla
mysql = 3.261.841
python = 3.261.884


SELECT count(*) 
FROM outgoing_bills o
WHERE	LOWER(is_canceled) in ('no', 'élő')
AND	item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
AND o.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND o.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
AND o.item_name_hun NOT IN ('Előleg')


####  SHIPPING_COUNTRY_STANDARDIZED and billing_country_standardized ###
country_mapping = dict(zip(IN_country_coding_unique['original_country'], IN_country_coding_unique['standardized_country']))
INVOICES_00['shipping_country_standardized'] = INVOICES_00['shipping_country'].map(country_mapping)

country_mapping = dict(zip(IN_country_coding_unique['original_country'], IN_country_coding_unique['standardized_country']))
INVOICES_00['billing_country_standardized'] = INVOICES_00['billing_country'].map(country_mapping)

INVOICES_00.loc[INVOICES_00['shipping_country_standardized'].isnull(), 'shipping_country_standardized'] = INVOICES_00['billing_country_standardized']
INVOICES_00.loc[INVOICES_00['billing_country_standardized'].isnull(), 'billing_country_standardized'] = INVOICES_00['shipping_country_standardized']


####  SHIPPING_ZIP_CODE and billing_zip_code ###
INVOICES_00['shipping_zip_code'] = INVOICES_00['shipping_zip_code'].str.replace('Somerset', '')
condition = (INVOICES_00['shipping_country_standardized'] == 'Romania') | (INVOICES_00['shipping_city'] == 'Bucuresti')
INVOICES_00.loc[condition, 'shipping_zip_code'] = INVOICES_00.loc[condition, 'shipping_zip_code'].str.lstrip('0')


INVOICES_00['billing_zip_code'] = INVOICES_00['billing_zip_code'].str.replace('Somerset', '')
condition = (INVOICES_00['billing_country_standardized'] == 'Romania') | (INVOICES_00['billing_city'] == 'Bucuresti')
INVOICES_00.loc[condition, 'billing_zip_code'] = INVOICES_00.loc[condition, 'billing_zip_code'].str.lstrip('0')



####  SHIPPING_CITY and billing_city ###
char_map = {'î': 'i', 'â': 'a', 'ă': 'a', 'ţ': 't', 'ș': 's'}
condition = INVOICES_00['shipping_country_standardized'] == 'Romania'
INVOICES_00.loc[condition, 'shipping_city'] = INVOICES_00.loc[condition, 'shipping_city'].replace(char_map, regex=True)


condition = INVOICES_00['billing_country_standardized'] == 'Romania'
INVOICES_00.loc[condition, 'billing_city'] = INVOICES_00.loc[condition, 'billing_city'].replace(char_map, regex=True)


## IN_city_coding bekódoló alapján - EZ A BLOKK NEM JÓ, ÁT KELL NÉZNI!!!
merged_df = INVOICES_00.merge(IN_city_coding, left_on=['shipping_country_standardized', 'shipping_city'], right_on=['original_country', 'original_city'], how='left')
mask = INVOICES_00['shipping_city'].isna()
INVOICES_00.loc[mask, 'shipping_city'] = merged_df.loc[mask, 'standardized_city']

merged_df = INVOICES_00.merge(IN_city_coding, left_on=['billing_country_standardized', 'billing_city'], right_on=['original_country', 'original_city'], how='left')
INVOICES_00['billing_city'] = merged_df['standardized_city'].fillna(INVOICES_00['billing_city'])
#INVOICES_00['billing_country_standardized'] = merged_df['standardized_country'].fillna(INVOICES_00['billing_country_standardized'])

# pár kivétel shipping_city alapján
merged_df = INVOICES_00.merge(IN_city_coding, left_on=['shipping_city'], right_on=['original_city'], how='left')
INVOICES_00['shipping_city'] = merged_df['standardized_city'].fillna(INVOICES_00['shipping_city'])
mask = INVOICES_00['shipping_country_standardized'].isna()
merged_df.loc[mask, 'standardized_country'] = INVOICES_00.loc[mask, 'shipping_country_standardized']


INVOICES_00.dropna(subset=['shipping_country_standardized'], inplace=True)
INVOICES_00.dropna(subset=['billing_country_standardized'], inplace=True)


teszt = INVOICES_00.loc[INVOICES_00['shipping_country_standardized'].isnull()] 
print(INVOICES_00.groupby("shipping_country_standardized").count())





####  standardized personal data table  ###
column_names = ['erp_id', 
                'shipping_name',
                'billing_name',
                'shipping_city', 
                'shipping_country',
                'shipping_country_standardized',
                'billing_city',
                'billing_country',
                'billing_country_standardized',
                'shipping_address',
                'billing_address',
                'shipping_zip_code',
                'billing_zip_code',
                'shipping_method',
                'shipping_phone']                ]
INVOICES_00_std = pd.DataFrame(columns=column_names)
INVOICES_00_std[column_names] = INVOICES_00[column_names]

INVOICES_00_std['shipping_country_length'] = INVOICES_00['shipping_country_standardized'].apply(len)
INVOICES_00_std['billing_country_length'] = INVOICES_00['billing_country_standardized'].apply(len)

INVOICES_00_std['shipping_city_length'] = INVOICES_00['shipping_city'].apply(len)
INVOICES_00_std['billing_city_length'] = INVOICES_00['billing_city'].apply(len)

INVOICES_00_std['hungary_shipping_flag'] = np.where((INVOICES_00_std['shipping_country_standardized'] == 'Hungary'), 1, 0)
INVOICES_00_std['romania_shipping_flag'] = np.where((INVOICES_00_std['shipping_country_standardized'] == 'Romania'), 1, 0)

INVOICES_00_std['hungary_billing_flag'] = np.where((INVOICES_00_std['billing_country_standardized'] == 'Hungary'), 1, 0)
INVOICES_00_std['romania_billing_flag'] = np.where((INVOICES_00_std['billing_country_standardized'] == 'Romania'), 1, 0)

# mező:  item_B2C_private_insurance
pattern_dict = {
    r'MKB EGÉSZSÉGPÉNZTÁR': 'MKB EGÉSZSÉGPÉNZTÁR',
    r'MKB(-PANNÓNIA)?': 'MKB-PANNÓNIA EGÉSZSÉG- ÉS ÖNSEGÉLYEZŐ PÉNZTÁR',
    r'MEDICINA': 'MEDICINA EGÉSZSÉGPÉNZTÁR',
    r'POSTÁS': 'POSTÁS EGÉSZSÉGPÉNZTÁR',
    r'OTP( ORSZÁGOS)?': 'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR',
    r'PATIKA': 'PATIKA EGÉSZSÉGPÉNZTÁR',
    r'ARANYKOR': 'ARANYKOR EGÉSZSÉGPÉNZTÁR',
    r'TEMPO': 'TEMPO EGÉSZSÉGPÉNZTÁR',
    r'AXA': 'AXA EGÉSZSÉGPÉNZTÁR',
    r'PRÉMIUM': 'PRÉMIUM EGÉSZSÉGPÉNZTÁR',
    r'VITAMIN': 'VITAMIN EGÉSZSÉGPÉNZTÁR',
    r'ÉLETERÖ': 'ÉLETERÖ EGÉSZSÉGPÉNZTÁR',
    r'ÉLETÚT': 'ÉLETÚT EGÉSZSÉGPÉNZTÁR',
    r'GENERALI': 'GENERALI EGÉSZSÉGPÉNZTÁR',
    r'HONVÉD': 'HONVÉD EGÉSZSÉGPÉNZTÁR',
    r'NAVOSZ': 'NAVOSZ EGÉSZSÉGPÉNZTÁR',
    r'QAESTOR': 'QAESTOR EGÉSZSÉGPÉNZTÁR',
    r'ADOSZT': 'ADOSZT EGÉSZSÉGPÉNZTÁR',
    r'(ÚJ )?PILLÉR': 'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR',
}

compiled_patterns = {re.compile(pattern): replacement for pattern, replacement in pattern_dict.items()}

def match_pattern(name):
    for pattern, replacement in compiled_patterns.items():
        if pattern.search(name):
            return replacement
    return ''

INVOICES_00_std['item_B2C_private_insurance'] = INVOICES_00_std.apply(lambda row: match_pattern(row['shipping_name'].upper()) or match_pattern(row['billing_name'].upper()), axis=1)


INVOICES_00_std['item_B2C_private_insurance'].unique()


selected_rows = INVOICES_00_std[INVOICES_00_std['item_B2C_private_insurance'] != ''].sample(50)


# mező:  SHIPPING_NAME_TRIM és billing_name_trim
pattern_dict = {
    r'EP\s?\d+': '',
    r'\d{5,20}': '',    
    r'MKB.*PÉNZTÁR': '',
    r'MKB.*EP': '',
    r'MEDICINA.*PÉNZTÁR': '',
    r'POSTÁS EGÉSZSÉGPÉNZTÁR': '',
    r'OTP.*PÉNZTÁR': '',
    r'PATIKA EGÉSZSÉGPÉNZTÁR': '',
    r'ARANYKOR EGÉSZSÉGPÉNZTÁR': '',
    r'TEMPO.*PÉNZTÁR': '',
    r'AXA EGÉSZSÉGPÉNZTÁR': '',
    r'PRÉMIUM.*PÉNZTÁR': '',
    r'VITAMIN EGÉSZSÉGPÉNZTÁR': '',
    r'ÉLETERÖ EGÉSZSÉGPÉNZTÁR': '',
    r'ÉLETÚT EGÉSZSÉGPÉNZTÁR': '',
    r'GENERALI.*PÉNZTÁR': '',
    r'HONVÉD EGÉSZSÉGPÉNZTÁR': '',
    r'NAVOSZ.*PÉNZTÁR': '',
    r'QAESTOR EGÉSZSÉGPÉNZTÁR': '',
    r'ADOSZT EGÉSZSÉGPÉNZTÁR': '',
    r'ÚJ PILLÉR.*PÉNZTÁR': '',
    r'PROVITA EGÉSZSÉGPÉNZTÁR': '',
    r'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR': '',
    r'KARDIREX EGÉSZSÉGPÉNZTÁR': '',
    r'VASUTAS EGÉSZSÉGPÉNZTÁR': '',
    r'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR': '',
    r'K&H MEDICINA EGÉSZSÉGPÉNZTÁR': '',
    r'K&H MEDICINA EP.': '',
    r'K&H': '',
    r'DIMENZIÓ EGÉSZSÉGPÉNZTÁR': '',
    r'DIMENZIO EGÉSZSÉGPÉNZTÁR': '',
    r'DANUBIUS EGÉSZSÉGPÉNZTÁR': '',  
    r'UNDEFINED': '',
    r'/': '',
    r'\(': '',
    r'\)': ''    
}

compiled_patterns = {re.compile(pattern): replacement for pattern, replacement in pattern_dict.items()}

def replace_patterns(name):
    for pattern, replacement in compiled_patterns.items():
        name = pattern.sub(replacement, name)
    return name

INVOICES_00_std['shipping_name_trim'] = INVOICES_00_std.apply(lambda row: replace_patterns(row['shipping_name'].upper()), axis=1)
INVOICES_00_std['billing_name_trim'] = INVOICES_00_std.apply(lambda row: replace_patterns(row['billing_name'].upper()), axis=1)




# mező:  SHIPPING_NAME_TRIM_WO_PICKUP és billing_name_trim_wo_pickup
pattern_dict = {
    r'EXON 2000': '',
    r'OMV ': '',    
    r'MOL ': '',
    r'NEMZETI DOHÁNYBOLT': '',
    r'OMW ': '',
    r'RELAY': '',
    r'INMEDIO': '',
    r'INMEDIÓ': '',
    r'ALLEGROUP.HU KFT.': '',
    r'OTP BANK NYRT': '',
    r'/ PPP': '',
    r'/PPP': '',
    r'PPPP': '',
    r'/ PM': '',
    r'/EP': '',
    r'/ TOF': '',
    r'/ SPRINTER': '',
    r' PP': '',
    r'/PP': ''
}

compiled_patterns = {re.compile(pattern): replacement for pattern, replacement in pattern_dict.items()}


INVOICES_00_std['shipping_name_trim_wo_pickup'] = INVOICES_00_std.apply(lambda row: replace_patterns(row['shipping_name_trim'].upper()), axis=1)
INVOICES_00_std['billing_name_trim_wo_pickup'] = INVOICES_00_std.apply(lambda row: replace_patterns(row['billing_name_trim'].upper()), axis=1)



# mező:  SHIPPING_NAME_FLAG és billing_name_flag
patterns = {
    r'bt\.? | bt | kft | zrt | nyrt | kkt | takarékszövetkezet|iroda|EV|egyéni vállalkozó | múzeum | egyház | misszió | központ | iskola | egyetem | óvoda | nébih | egyesület | alapítvány | foundation | association | ltd\.? | ltda | plc\.? | fiók | limited | s\.r\.l\. | s\.r\.o\. | s\.p\.a\. | s\.n\.c\. | s\.a\.s\. | iroda| EV|egyéni vállalkozó': 'business',
    r'/tof|/ tof|ppp|/ pm|/pm|/pp|/ pp|sprinter|exon 2000| omv|omv |mol benzinkút|mol töltőállomás|nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj': 'pickup'
}  


for pattern, category in patterns.items():
    mask = INVOICES_00_std['shipping_name'].str.strip().str.contains(pattern, flags=re.IGNORECASE)
    INVOICES_00_std.loc[mask, 'shipping_name_flag'] = category

# set 'real' category for non-matching rows
non_matching_mask = INVOICES_00_std['shipping_name_flag'].isna()
INVOICES_00_std.loc[non_matching_mask, 'shipping_name_flag'] = 'real'



for pattern, category in patterns.items():
    mask = INVOICES_00_std['billing_name'].str.strip().str.contains(pattern, flags=re.IGNORECASE)
    INVOICES_00_std.loc[mask, 'billing_name_flag'] = category

# set 'real' category for non-matching rows
non_matching_mask = INVOICES_00_std['billing_name_flag'].isna()
INVOICES_00_std.loc[non_matching_mask, 'billing_name_flag'] = 'real'



# mező:  SHIPPING_PHONE
pattern_dict = {
    r'^20': '+3620',
    r'^30': '+3630',
    r'^70': '+3670',
    r'^3600': '',
    r'^\+3600': '',
    r' ': '',    
    r'-': ''
}

compiled_patterns = {re.compile(pattern): replacement for pattern, replacement in pattern_dict.items()}

def replace_patterns(name):
    for pattern, replacement in compiled_patterns.items():
        name = pattern.sub(replacement, name)
    return name

INVOICES_00_std['shipping_phone_clean'] = INVOICES_00_std.apply(lambda row: replace_patterns(row['shipping_phone'].upper()), axis=1)



pattern = {
    r'\+?(36|06)[ /.-]*(\d{1,2})[ /.-]*(\d+)': 'Hungary',
    r'\+?(39)[ /.-]*(\d{1,2})[ /.-]*(\d+)': 'Italy'    
    }


def clean_phone_number(phone_number, country):
        for regex, country_code in pattern.items():
            match = re.search(regex, phone_number)
            if match:
                if country == 'Hungary':
                    return '+36' + match.group(2) + match.group(3)
                elif country == 'Italy':
                    return '+39' + match.group(2) + match.group(3)
                else:
                    return ''



INVOICES_00_std['shipping_phone_clean'] = INVOICES_00_std.apply(lambda x: clean_phone_number(x['shipping_phone_clean'], x['shipping_country_standardized']), axis=1)


INVOICES_00_std.loc[INVOICES_00_std['erp_id'] == 'SO12/00444', ['erp_id','shipping_phone', 'shipping_phone_clean']]


selected_rows = INVOICES_00_std.loc[INVOICES_00_std['shipping_country_standardized'] == 'Romania', ['erp_id','shipping_country_standardized','shipping_phone', 'shipping_phone_clean']].sample(500)



'SO13/02763'
'SO12/00484'
'SO11/02023'
SO15/02227
SO12/00444



string = '+393920281784'

strings = ['36 70 2802555', '+36-20-3888984', '+36702802555', '+36-1-4370265']
pattern = r'\+?36[ .-]?(\d{1,2})[ .-]?(\d+)'

for string in strings:
    match = re.search(pattern, string)
    if match:
        phone_number =  '+36' + match.group(1) + match.group(2)
        print(phone_number)
    else:
        print("No match")



selected_rows = INVOICES_00_std.sample(500)







####  KUKA ###
pattern = r'Somerset'
mask = INVOICES_00['shipping_zip_code'].str.contains(pattern, flags=re.IGNORECASE)
INVOICES_00_filtered = INVOICES_00[mask]



pattern = r'Wien'
mask = INVOICES_00['shipping_city'].str.contains(pattern, flags=re.IGNORECASE)
INVOICES_00_filtered = INVOICES_00[mask]



rer = INVOICES_00[INVOICES_00['shipping_country_standardized'].isna() == True].tail(100)

