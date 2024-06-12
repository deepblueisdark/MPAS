import os
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timedelta

# Função para formatar a data
def format_date(date_str):
    date_obj = datetime.strptime(date_str, "%d/%m/%Y")
    year = date_obj.strftime("%Y")
    month = date_obj.strftime("%m")
    day = date_obj.strftime("%d")
    return year, month, day

# Função para baixar arquivos .grb2 e .inv de uma data específica
def download_files(date_str):
    year, month, day = format_date(date_str)
    url = f"https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-ocean/{year}/{year}{month}/{year}{month}{day}/{year}{month}{day}00/"

    output_dir = "SST_CFS"
    os.makedirs(output_dir, exist_ok=True)

    response = requests.get(url)
    if response.status_code != 200:
        print(f"Não foi possível acessar a URL: {url}")
        return

    soup = BeautifulSoup(response.text, 'html.parser')

    file_links = []
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and (href.endswith('.grb2') or href.endswith('.inv')):
            file_links.append(url + href)

    for file_link in file_links:
        file_name = file_link.split('/')[-1]
        file_path = os.path.join(output_dir, file_name)
        
        print(f"Baixando {file_name}...")
        file_response = requests.get(file_link)
        
        with open(file_path, 'wb') as file:
            file.write(file_response.content)
        
        print(f"{file_name} salvo em {file_path}")

    print("Download concluído.")

# Exemplo de uso
#
#
#
data_inicio = '31/05/2024'
download_files(data_inicio)
