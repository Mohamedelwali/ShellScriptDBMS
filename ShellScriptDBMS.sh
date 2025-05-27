
#!/bin/bash

DB_DIR="./databases"

# Ensure databases directory exists
mkdir -p "$DB_DIR"

main_menu() {
    while true; do
        echo "====== DBMS Main Menu ======"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -p "Select an option [1-5]: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}




main_menu
