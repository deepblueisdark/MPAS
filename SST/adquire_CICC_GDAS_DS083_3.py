
import os
import requests
from datetime import datetime

def download_grib2(year, month, day, run, output_dir):
    # Define the earliest allowed date
    earliest_date = datetime(2015, 7, 8)
    current_date = datetime(year, month, day)

    # Check if the current date is earlier than the earliest allowed date
    if current_date < earliest_date:
        print(f"Date {current_date.strftime('%Y-%m-%d')} is earlier than the earliest allowed date {earliest_date.strftime('%Y-%m-%d')}.")
        return

    # Construct the URL
    base_url = "https://thredds.rda.ucar.edu/thredds/fileServer/files/g/ds083.3"
    url = f"{base_url}/{year}/{year}{month:02d}/gdas1.fnl0p25.{year}{month:02d}{day:02d}{run:02d}.f00.grib2"
    
    # Create the output directory if it does not exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Construct the output file path
    file_name = f"gdas1.fnl0p25.{year}{month:02d}{day:02d}{run:02d}.f00.grib2"
    output_file = os.path.join(output_dir, file_name)
    
    # Download the file
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(output_file, 'wb') as file:
            for chunk in response.iter_content(chunk_size=1024):
                file.write(chunk)
        print(f"Download complete: {output_file}")
    else:
        print(f"Failed to download file. HTTP Status code: {response.status_code}")

# Example usage
year = 2015
month = 7
day = 8
run = 0  # Choose from 00, 06, 12, 18
output_dir = "./GDAS"

download_grib2(year, month, day, run, output_dir)
