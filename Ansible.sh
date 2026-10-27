#!/bin/bash
#
# Цель: автоматическая установка Ansible на Debian/Ubuntu Desktop
# Поддерживаемые системы: Ubuntu 20.04 / 22.04 / 24.04 / 26.04, Debian 11/12/13


set -e

# Проверка прав root. (Здесь можно использовать sudo или через su)
if [[ "${UID}" -ne 0 ]]; then
    echo 'Скрипт нужно запускать с правами sudo или root' >&2
    exit 1
fi

# Определяем пользователя, который вызвал sudo (для прав на создаваемые каталоги)
if [[ -n "${SUDO_USER}" ]]; then
    TARGET_USER="${SUDO_USER}"
    TARGET_HOME=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
else
    TARGET_USER="root"
    TARGET_HOME="/root"
fi

# Определяем дистрибутив и версию
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID="${ID}"
    OS_CODENAME="${VERSION_CODENAME}"
    OS_VERSION="${VERSION_ID}"
else
    echo "Не удалось определить дистрибутив (/etc/os-release отсутствует)" >&2
    exit 1
fi

echo ">>> Обнаружена система: ${PRETTY_NAME}"

# Обновление системы
echo ">>> Обновление списка пакетов..."
apt-get update -y

echo ">>> Обновление установленных пакетов..."
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Установка вспомогательных пакетов
echo ">>> Установка вспомогательных пакетов..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    gnupg \
    curl \
    ca-certificates \
    lsb-release \
    python3 \
    python3-pip \
    sshpass

# Добавление репозитория Ansible
if [[ "${OS_ID}" == "ubuntu" ]]; then
    echo ">>> Добавление PPA ansible/ansible (Ubuntu)..."
    add-apt-repository -y ppa:ansible/ansible
    apt-get update -y

elif [[ "${OS_ID}" == "debian" ]]; then
    echo ">>> Добавление официального репозитория Ansible (Debian)..."
    install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/ansible-archive-keyring.gpg ]]; then
        curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get\&search=0x93C4A3FD7BB9C367 \
            | gpg --dearmor -o /etc/apt/keyrings/ansible-archive-keyring.gpg
        chmod a+r /etc/apt/keyrings/ansible-archive-keyring.gpg
    fi

    echo "deb [signed-by=/etc/apt/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu ${OS_CODENAME} main" \
        > /etc/apt/sources.list.d/ansible.list

    apt-get update -y
else
    echo "Дистрибутив ${OS_ID} не поддерживается этим скриптом." >&2
    exit 1
fi

# Установка Ansible
echo ">>> Установка Ansible..."
DEBIAN_FRONTEND=noninteractive apt-get install -y ansible

# Проверка
if ! command -v ansible >/dev/null 2>&1; then
    echo "Не удалось установить Ansible" >&2
    exit 1
fi

ANSIBLE_VERSION=$(ansible --version | head -n1)
echo ">>> Установлено: ${ANSIBLE_VERSION}"
echo ">>> Файлы конфигурации по умолчанию находятся в /etc/ansible"

# Базовая структура каталогов в домашнем каталоге пользователя
echo ">>> Создание базовой структуры каталогов в ${TARGET_HOME}..."
mkdir -p "${TARGET_HOME}/ansible/Playbooks" \
         "${TARGET_HOME}/ansible/Tasks" \
         "${TARGET_HOME}/ansible/Handlers" \
         "${TARGET_HOME}/ansible/Roles" \
         "${TARGET_HOME}/ansible/Inventory"

# Права владельца — на вызвавшего sudo пользователя
chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/ansible"

echo
echo "======================================================"
echo " Ansible успешно установлен!"
echo " Проверка:        ansible --version"
echo " Конфиг:          /etc/ansible/ansible.cfg"
echo " Рабочий каталог: ${TARGET_HOME}/ansible"
echo "======================================================"

exit 0
