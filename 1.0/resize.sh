#!/bin/bash

# Autheur : Benjamin RABILLER
# Version 1.0
# Descritpion : Ce script renomme, c'est a dire qu'il supprime les espaces des noms de fichier
# et reduit la taille de photos presente dans un repertoire en fonction de leur poids (en Mo)
# Dependance : Ce script necessite l'installation pr√alable de IMAGEMAGICK

CHEMIN=$1
declare -a TAB # Declare un tableau qui contiendra les bornes 

param_test(){
    if [ -d "$CHEMIN" ]; then
	echo "Repertoire valide" 
	cpt=$(ls $CHEMIN | grep -E "jpg|JPG|png|PNG" | wc -l) # Recupere le nombre d'images presentes dans le repertoire
	if [ $cpt -eq 0 ]; then
    	echo "Aucune image dans ce dossier"
    	exit 1
	fi
	else
		echo "Vous devez renter un chemin vers un repertoire valide"
		exit 1
    fi
}

# La fonction init laisse le choix a l'utilisateur de selectionner le mode par defaut (bornes predefinis) 
# ou bien de choisir ses propres bornes au nombre de 7 indiqu√es en Mo
init(){
    echo "Quel mode souhaitez vous utiliser ?"
    echo "Mode par defaut (1) ou personnalise (2) :"
    read choix
    if [ "$choix" = "1" ]; then
        TAB=( 629146 1048576 2097152 3145728 4194304 5242880 6291456 )
    else
        echo "SELECTION DES BORNES (7 sont a rentrer)"
        echo "LA TAILLE DOIT ETRE INDIQUEE EN Mo !"
        local j=0
        while [ $j != 7 ]; do
        	echo -n "BORNE $j : "
        	read borne
			echo -n " Mo"
        	taille=$(convertion "$borne")
            TAB[$j]=$taille
            j=$(($j + 1))
        done
	fi
}

# La fonction convertion permet de realiser les calculs avec des float afin de convertir
# les nombres en Mo en Ko
convertion(){
        mo_to_kb=$(echo "(1048576*$1)" | bc) #Pour calculer avec des float
        borne=$(echo "($mo_to_kb/1)" | bc) #On enleve le .0 de la fin
        echo $borne
}

# La fonction rename se charge d'enlever les espaces de chaque nom de fichier
rename(){
		TROUVE=0
        echo $1 | grep -q " "
        if [ $? -eq $TROUVE ]; then
		    nomf=$1
		    n=$(echo $nomf | sed -e 's/ /_/g')
		    mv "$nomf" "$n"
		    echo $n
		else
			echo $1
		fi
}

# La fonction resize utilise imagemagick afin de reduire la taille des images en fonction
# des bornes
resize(){
	local i=1
	for fic in $(ls $CHEMIN | grep -E "jpg|JPG|png|PNG")
	do
		res1=$(($i * 100)) 
		res2=$(($res1 / $cpt))
		echo -ne "### PROGRESSION : $res2 % ###\r"
		fichier=$(rename "$fic")
		fichier=$CHEMIN$fichier
		size=$(stat -c "%s" $fichier)
	
		    if [ $size -ge ${TAB[0]} ] && [ $size -le ${TAB[1]} ]; then
		        convert -resize "98%" $fichier $fichier
		    elif [ $size -le ${TAB[1]} ]; then
		        convert -resize "90%" $fichier $fichier
		    elif [ $size -le ${TAB[2]} ]; then
		        convert -resize "60%" $fichier $fichier
		    elif [ $size -le ${TAB[3]} ]; then
		        convert -resize "50%" $fichier $fichier
		    elif [ $size -le ${TAB[4]} ]; then
		        convert -resize "40%" $fichier $fichier
		    elif [ $size -le ${TAB[5]} ]; then
		        convert -resize "30%" $fichier $fichier
		    elif [ $size -le ${TAB[6]} ]; then
		        convert -resize "20%" $fichier $fichier
		else
		        convert -resize "10%" $fichier $fichier
		fi
		i=$(($i + 1))
	done
}

main(){
    param_test 
    init 
    resize 
}

main 
exit 0
