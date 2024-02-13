#!/bin/bash

source /home/sl1mshady/useful_scripts/phoenix/color.sh

process_input() { #Testing if input is a file or a singular host
    input=$1
    if [[ -f $input ]]; then
        while IFS= read -r target; do
            execute_test "$target"
        done < "$input"
    else
        execute_test "$input"
    fi
}

execute_test() {
    target=$1
    case $option in
        1)
            ./infraexternal.sh "$target"
            ;;
        2)
            #./infrainternal.sh "$target"
            ;;
        3)
            #./infraapi.sh "$target"
            ;;
        4)
            #./infraweb.sh "$target"
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
}

# Função principal para escolher o tipo de teste e processar os alvos
main() {
	echo -e "${red}${bold}"
	cat << 'EOF'
	 .\\            //.
	. \ \          / /.
	.\  ,\     /` /,.
	 -.   \  /\/ /  .
	 ` -   `-'  \  -
	   '.       /.\`
	      -    .-
	      :`//.'
	      .`.'
	      .'
EOF
	echo -e "${reset}"
	echo -e "      ${red}PHOENIX by ${bold}${white}sl1mshady${reset}"
	echo ""
    	echo "Which tests do you want to do?"
    	echo "1) External Infrastructure"
    	echo "2) Internal Infrastructure"
    	echo "3) API Infrastructure"
    	echo "4) Web Infrastructure"
    	echo "0) Exit"

    read -p "Choose an option (1-4): " option
    if [[ $option == 0 ]]; then
        echo "Exiting the script..."
        exit 0
    fi

    read -p "Enter your target (IP, URL or path to target list file): " input

    process_input "$input"
}

main
