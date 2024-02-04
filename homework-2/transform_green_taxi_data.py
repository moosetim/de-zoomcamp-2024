import pandas as pd

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    print("Unique VendorID's: {0}".format(data['VendorID'].unique()))
    unique_vendor_id_list = [vid for vid in data['VendorID'].unique() if vid is not pd.NA]
    print("Unique VendorID's without <NA> values: {}".format(unique_vendor_id_list))

    print('Shape of the dataset BEFORE preprocessing: {0}'.format(data.shape))

    print('Preprocessing:')
    
    print('Remove rows where the passenger count is equal to 0 or the trip distance is equal to zero.')
    data = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)]
    print('Shape of the dataset AFTER preprocessing: {0}'.format(data.shape))

    print('Create a new column lpep_pickup_date by converting lpep_pickup_datetime to a date.')
    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    print('Rename columns in Camel Case to Snake Case, e.g. VendorID to vendor_id.')
    data.rename(columns = {
        'VendorID': 'vendor_id',
        'RatecodeID': 'ratecode_id',
        'PULocationID': 'pu_location_id',
        'DOLocationID': 'do_location_id'
        }, 
        inplace=True
    )

    return data


@test
def test_passenger_count(output, *args) -> None:
    assert output['passenger_count'].isin([0]).sum() == 0, 'There are rides with zero passengers'

@test
def test_trip_distance(output, *args) -> None:
    assert output['trip_distance'].isin([0]).sum() == 0, 'There are trips with zero distance'

@test
def test_vendor_id_values(output, *args) -> None:
    assert output[~output['vendor_id'].isin([1,2])].empty, 'There are vendor_id values that are not one of the existing values'