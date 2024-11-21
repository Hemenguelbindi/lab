#!/bin/bash

# Логирование всех шагов
exec > >(tee -i /tmp/provision.log)
exec 2>&1

echo "Обновление системы..."
sudo apt-get update || { echo "Ошибка при обновлении"; exit 1; }
sudo apt-get -y upgrade || { echo "Ошибка при апгрейде"; exit 1; }

echo "Установка зависимостей для Grafana..."
sudo apt-get install -y apt-transport-https software-properties-common wget || { echo "Ошибка при установке зависимостей"; exit 1; }
sudo mkdir -p /etc/apt/keyrings/ || { echo "Ошибка при создании директории keyrings"; exit 1; }
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null || { echo "Ошибка при загрузке ключа Grafana"; exit 1; }
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list || { echo "Ошибка при добавлении репозитория Grafana"; exit 1; }
sudo apt-get update -y || { echo "Ошибка при обновлении репозиториев"; exit 1; }

echo "Установка Grafana..."
sudo apt-get install grafana -y || { echo "Ошибка при установке Grafana"; exit 1; }

echo "Запуск и включение Grafana..."
sudo systemctl daemon-reload || { echo "Ошибка при перезагрузке демонов"; exit 1; }
sudo systemctl start grafana-server || { echo "Ошибка при запуске Grafana"; exit 1; }
sudo systemctl enable grafana-server.service || { echo "Ошибка при включении Grafana на старте"; exit 1; }

echo "Скрипт завершен успешно!"
