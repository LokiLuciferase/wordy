#!/usr/bin/env bash
#
#╻ ╻┏━┓┏━┓╺┳┓╻ ╻
#┃╻┃┃ ┃┣┳┛ ┃┃┗┳┛
#┗┻┛┗━┛╹┗╸╺┻┛ ╹
#
#A bash script written by Christos Angelopoulos, September 2023, under GPL v2

Y="\033[1;33m"
G="\033[1;32m"
C="\033[1;36m"
M="\033[1;35m"
R="\033[1;31m"
B="\033[1;34m"
W="\033[1;37m"
E="\033[1;30m"
bold=$(tput bold)
norm=$(tput sgr0)

TOTAL_SOLUTIONS="$(look . |grep -v "'"|grep -v -E "[ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]" | grep -v '[^[:lower:]]' | grep -E "^.....$")"
STATFILE="$HOME/.cache/wordy/statistics.txt"
DB=""
DB2=""
EXPENDED=""
BACKSPACE=$(cat << eof
0000000 005177
0000002
eof
)

ensure_statfile(){
    if [[ ! -f "$STATFILE" ]]; then
        mkdir -p "$(dirname "$STATFILE")"
        touch "$STATFILE"
    fi
}

quit_puzzle(){
    echo -e "╻ ╻┏━┓┏━┓╺┳┓╻ ╻\n┃╻┃┃ ┃┣┳┛ ┃┃┗┳┛\n┗┻┛┗━┛╹┗╸╺┻┛ ╹\n"
	A=${SOLUTION^^}
	echo -e "${Y}${bold}The word you were looking for was:"
	echo -e "     ${G}╭───╮╭───╮╭───╮╭───╮╭───╮     \n     │ ${A:0:1} ││ ${A:1:1} ││ ${A:2:1} ││ ${A:3:1} ││ ${A:4:1} │     \n     ╰───╯╰───╯╰───╯╰───╯╰───╯ ${norm}    "
	echo -e "\nPress any key to return"
	read -rsN 1 v
    clear
	DB2="M"
}

show_statistics(){
    echo -e "${Y}${bold}┏━┓╺┳╸┏━┓╺┳╸╻┏━┓╺┳╸╻┏━╸┏━┓\n┗━┓ ┃ ┣━┫ ┃ ┃┗━┓ ┃ ┃┃  ┗━┓\n┗━┛ ╹ ╹ ╹ ╹ ╹┗━┛ ╹ ╹┗━╸┗━┛${norm}\n\n"
    local played won suc_ratio record max_row
    played="$(cat "$STATFILE" | wc -l)"
    won="$(cat "$STATFILE" | grep -c win)"
    suc_ratio="$(echo "scale=2; $won *100/ $played" | bc)"
    record="$(sort "$STATFILE" | head -1 | awk '{print $1}')"
    max_row="$(uniq -c -s 1 "$STATFILE" | head -1 | awk '{print $1}')"
    echo -e "Games Played     : $played\nGames Won        : $won\nGames Lost       : $((played-won))\nSuccess ratio    : $suc_ratio%\nRecord Guesses   : $record\nMax wins in a row: $max_row\n"
}

win_game(){
	clear
	((TRY++))
	echo "$TRY win" >> "$STATFILE"
	PLACEHOLDER_STR=$SOLUTION
	F[TRY]="GGGGG"
	print_box
	echo "╰───────────────────────────────────╯"
	A=${PLACEHOLDER_STR^^}
	echo -e "${Y}${bold}Congratulations!\nYou found the word:"
	echo -e "     ${G}╭───╮╭───╮╭───╮╭───╮╭───╮     \n     │ ${A:0:1} ││ ${A:1:1} ││ ${A:2:1} ││ ${A:3:1} ││ ${A:4:1} │     \n     ╰───╯╰───╯╰───╯╰───╯╰───╯ ${norm}    "
	echo -e "${Y}${bold}after ${R}$TRY ${Y}tries!${norm}\n"
	echo -e "\nPress any key to return"
	read -rsN 1 v
    clear
	DB2="M"
}

lose_game(){
	clear
	#((TRY++))
	echo "lose" >> "$STATFILE"
	PLACEHOLDER_STR=$SOLUTION
	F[TRY]="GGGGG"
	print_box
	echo "╰───────────────────────────────────╯"
	echo -e "${Y}${bold}You lost!\nAfter ${R}6${Y} tries,\n it was not possible to find the word\n"
	A=${PLACEHOLDER_STR^^}
    echo -e "     ${G}╭───╮╭───╮╭───╮╭───╮╭───╮     \n     │ ${A:0:1} ││ ${A:1:1} ││ ${A:2:1} ││ ${A:3:1} ││ ${A:4:1} │     \n     ╰───╯╰───╯╰───╯╰───╯╰───╯ ${norm}    "
	echo -e "\nPress any key to return"
    read -rsN 1 v
    clear
	DB2="M"
}

check_guess(){
	F0=('R' 'R' 'R' 'R' 'R')
	for q in {0..4}; do
        if [[ "${WORD_STR:q:1}" == "${SOLUTION:q:1}" ]]; then
            F0[q]="G"
        elif [[ "$SOLUTION" == *"${WORD_STR:q:1}"* ]]; then
            F0[q]="Y"
        else
            EXPENDED="${EXPENDED}${WORD_STR:q:1}"
        fi
		F[TRY]=$(echo ${F0[@]} | sed 's/ //g')
	done
    EXPENDED="$(echo "$EXPENDED" | tr -s 'a-z' | grep -o . | sort | uniq | tr -d '\n')"
    EXPENDED=${EXPENDED^^}
    COMMENT=" Enter 5 letter word"
}

enter_word(){
	if [[ ${#WORD_STR} -lt 5 ]]; then
        COMMENT=" Word is too small!"
	elif [[ ${#WORD_STR} -gt 5 ]]; then
        COMMENT=" Word too big!"
	elif [[ -z "$(echo "$TOTAL_SOLUTIONS" |sed 's/ /\n/g'|grep  -E ^"$WORD_STR"$)" ]]; then
        COMMENT=" Invalid word, not in solutions"
	else
		COMMENT=" Last word: $WORD_STR"
		GUESS[$TRY]=$WORD_STR
		check_guess
		if [[ "${F[TRY]}" == "GGGGG" ]]
		then win_game
		main_menu_reset
		else
			((TRY++))
			if [[ $TRY -ge 6 ]]
				then lose_game
				main_menu_reset
			fi
		fi
	fi
	WORD_STR=""
    PLACEHOLDER_STR="${WORD_STR}${PAD}"
	COMMENT_STR="${COMMENT}${PAD}"
	#get_rank
}

main_menu_reset(){
    for i in {0..5}; do
        F[i]=""
    done
}

print_box(){
	echo "╭───────────────────────────────────╮"
    local t=0
    while [[ $t -lt $TRY ]]; do
        A="${GUESS[$t]^^}"
        K0="${F[$t]}"
        for a in {0..4}; do
            if [[ ${K0:a:1} == "Y" ]]; then
                K[a]="${Y}"
            elif [[ ${K0:a:1} == "G" ]]; then
                K[a]="${G}"
            elif [[ ${K0:a:1} == "R" ]]; then
                K[a]="${R}"
            fi
        done
        echo -e "│     ${K[0]}╭───╮${K[1]}╭───╮${K[2]}╭───╮${K[3]}╭───╮${K[4]}╭───╮${norm}     │\n│     ${K[0]}│ ${A:0:1} │${K[1]}│ ${A:1:1} │${K[2]}│ ${A:2:1} │${K[3]}│ ${A:3:1} │${K[4]}│ ${A:4:1} │${norm}     │\n│     ${K[0]}╰───╯${K[1]}╰───╯${K[2]}╰───╯${K[3]}╰───╯${K[4]}╰───╯${norm}     │"
        ((t++))
    done

    if [[ ${F[TRY]} != "GGGGG" ]]; then
        A=${PLACEHOLDER_STR^^}
        fmt=( '' '' '' '' '' )
        for i in {0..4}; do
            if [[ "$EXPENDED" == *"${A:i:1}"* ]]; then
                fmt[i]="$E"
            else
                fmt[i]=""
            fi
        done
        echo "│     ╭───╮╭───╮╭───╮╭───╮╭───╮     │"
        echo -e "│     │ ${fmt[0]}${A:0:1}${norm} ││ ${fmt[1]}${A:1:1}${norm} ││ ${fmt[2]}${A:2:1}${norm} ││ ${fmt[3]}${A:3:1}${norm} ││ ${fmt[4]}${A:4:1}${norm} │     │"
        echo "│     ╰───╯╰───╯╰───╯╰───╯╰───╯     │"
        echo "├───────────────────────────────────┤"
    fi
}

rules() {
	echo -e "You have 6 guesses to find out the secret 5-letter word.

    ${G}╭───╮
    ${G}│ F │
    ${G}╰───╯${norm}
    If a letter appears ${R}${bold}green${norm},that means that this letter
    ${G}${bold}exists in the secret word, and is in the right position${norm}.

    \t${Y}╭───╮
    \t${Y}│ F │
    \t${Y}╰───╯${norm}
    If a letter appears ${Y}${bold}yellow${norm},that means that this letter
    ${Y}${bold}exists in the secret word, but is in NOT the right position${norm}.

    \t\t${R}╭───╮
    \t\t${R}│ F │
    \t\t${R}╰───╯${norm}
    If a letter appears ${R}${bold}red${norm},that means that this letter
    ${R}${bold}does NOT appear in the secret word AT ALL${norm}.
    As mentioned above, there are ${Y}${bold}6 guesses${norm} to find the secret word.
    ${Y}${bold}GOOD LUCK!${norm}
    \n\nPress any key to return"

    read -rsN 1
    clear
}

new_game(){
	PAD="                                      "
	COMMENT=" Enter 5 letter word"
	COMMENT_STR="${COMMENT}${PAD}"
	PLACEHOLDER_STR="$WORD_STR${PAD}"
	SOLUTION="$(look . | grep -v "'" | grep -v -E "[ê,è,é,ë,â,à,ô,ó,ò,ú,ù,û,ü,î,ì,ï,í,ç,ö,á,ñ]" | grep -v '[^[:lower:]]'| grep -E "^.....$" | shuf | head -1)"
	TRY=0
}

play_menu(){
    DB2="";

	while [[ $DB2 != "M" ]]; do
		print_box
		echo -en "│   ${Y}${bold}<enter>${norm}    to ${G}${bold}ACCEPT word${norm}       │\n│  ${Y}${bold}<delete>${norm}    to ${R}${bold}ABORT word${norm}        │\n│ ${Y}${bold}<backspace>${norm}  to ${R}${bold}DELETE letter${norm}     │\n├───────────────────────────────────┤\n│      ${Y}${bold}W${norm}       to show ${C}${bold}WORD LIST${norm}    │\n├───────────────────────────────────┤\n│      ${Y}${bold}M${norm}       to go to ${G}${bold}MAIN MENU${norm}   │\n│      ${Y}${bold}N${norm}       to play  ${G}${bold}NEW GAME${norm}    │\n│      ${Y}${bold}Q${norm}       to ${R}${bold}QUIT GAME${norm}         │\n├───────────────────────────────────┤\n│${COMMENT_STR:0:35}│\n╰───────────────────────────────────╯\n"
		read -rsn 1 DB2
		if [[ $(echo "$DB2" | od) = "$BACKSPACE" ]] && [[ ${#WORD_STR} -gt 0 ]]; then
            WORD_STR="${WORD_STR::-1}"
            PLACEHOLDER_STR="${WORD_STR}${PAD}"
        fi
        case $DB2 in
            "M")
                clear
                DB=""
                main_menu_reset
            ;;
            "N")
                clear
                new_game
                clear
            ;;
            "Q")
                clear
                quit_puzzle
            ;;
            [a-z])
                clear
                if [[ ${#WORD_STR} -le 5 ]]; then
                    WORD_STR="${WORD_STR}${DB2}"
                    PLACEHOLDER_STR="${WORD_STR}${PAD}"
                fi
            ;;
            "")
                clear
                enter_word
            ;;
            "3")
                clear
                WORD_STR=""
                PLACEHOLDER_STR="${WORD_STR}${PAD}"
            ;;
            "W")
                clear
                echo -e "${Y}${bold}ALL POSSIBLE WORDS ($TOTAL_SOLUTIONS_NUMBER)${norm}\n\n$(echo $TOTAL_SOLUTIONS | sed 's/ /\n/g')\n\n${Y}${bold}Press any key to return${norm}"
                read -rsN 1
                clear
            ;;
            *)
            clear
        esac
    done
}

main(){
    clear
    ensure_statfile
    main_menu_reset
    while [ "$DB" != "4" ]; do
        echo "╭───────────────────────────────────╮"
        echo -e "│     ${G}╭───╮${G}╭───╮${G}╭───╮${G}╭───╮${R}╭───╮     ${norm}│\n│     ${G}│ W │${G}│ O │${G}│ R │${G}│ D │${R}│ Y │     ${norm}│\n│     ${G}╰───╯${G}╰───╯${G}╰───╯${G}╰───╯${R}╰───╯     ${norm}│\n├───────────────────────────────────┤\n│   ${C}${bold}Find the hidden 5 letter word${norm}   │"
        echo -en "├───────────────────────────────────┤\n│Enter:                             │\n│ ${Y}${bold}1${norm} to ${G}${bold}Play New Game${norm}.               │\n│ ${Y}${bold}2${norm} to ${C}${bold}Read the Rules${norm}.              │\n│ ${Y}${bold}3${norm} to ${C}${bold}Show Statistics${norm}.             │\n│ ${Y}${bold}4${norm} to ${R}${bold}Exit${norm}.                        │\n"
        echo  -e "╰───────────────────────────────────╯\n"
        read -rsN 1 DB
        case $DB in
            1)
                clear
                new_game
                play_menu
                clear
            ;;
            2)
                clear
                rules
            ;;
            3)
                clear
                show_statistics
                echo -e "\nPress any key to return"
                read -rsN 1
                clear
            ;;
            4)
                clear
            ;;
            *)
                clear
                echo -e "\n😕 ${Y}${bold}${DB}${norm} is an invalid key, please try again.\n"
        esac
    done
}

main
