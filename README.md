 Ansible.sh

 Скрипт для автоматической установки Ansible (Script for automatic installation of Ansible) Подходит для систем Debian/Ubuntu Особенности:
    1. Убран жёсткий PermitRootLogin no — на десктопе это обычно не нужно, а на некоторых установках может не быть /etc/ssh/sshd_config. 
    2. Поддержка Debian и Ubuntu — PPA ppa:ansible/ansible работает только на Ubuntu. Для Debian добавлен официальный репозиторий Ansible. 
    3. Установка вспомогательных пакетов (software-properties-common, gnupg, curl, sshpass) — без них add-apt-repository и работа с ключами могут упасть. 
    4. Проверка установки — фейл, если ansible не появился в PATH. 
Запуск и Права
chmod +x Аnsible.sh
sudo ./Аnsible.sh

  in english
Script for automatic installation of Ansible. Suitable for Debian/Ubuntu systems Features:
    1. Removed the hard PermitRootLogin no - on a desktop this is usually not needed, and on some installations there may not be /etc/ssh/sshd_config. 
    2. Debian and Ubuntu support - PPA ppa:ansible/ansible only works on Ubuntu. An official Ansible repository has been added for Debian. 
    3. Installing auxiliary packages (software-properties-common, gnupg, curl, sshpass) - without them, add-apt-repository and working with keys may fail. 
    4. Installation check - fail if ansible does not appear in PATH. 
Launch and Rights
chmod +x Ansible.sh
sudo ./Ansible.sh
