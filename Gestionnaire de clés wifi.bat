@echo off
setlocal enableDelayedExpansion
title Cle manager ammeliorer
color 74
rem
:recommencer
cls
netsh wlan show profiles > temporaire.txt
set indice=0
                rem Cette boucle parcoure le fichier et recupere les noms des modems  dans un tableau
for /f "tokens=2 delims=:" %%a in ('type "temporaire.txt" ^| findstr /c:utilisateur') do (
	set tableau_nom[!indice!]=%%a
    set /a indice=indice + 1
)
del temporaire.txt
set /a indice-=1
echo                                              Menu
echo.
echo -----------------------------------------------------------------------------------------------
echo.
echo Voici la liste des noms de point d'accees auquel vous vous etes deja connecter :
echo.
                    rem Cette boucle va de 0 a la valeur que la variable indice contient
for /L %%i in (0,1,%indice%) do (
    set /a increment=%%i+1
    echo!tableau_nom[%%i]!: >> numero.txt
    echo                                N !increment! : !tableau_nom[%%i]!
)
echo.
echo ----------------------------------------------------------------------------------------------
echo.
echo.
echo.
set /p numero=Tapez le numero associer au SSID (nom de point d'accees) et appuyer sur entree :
set nom=
set code=false
set nb_ligne=0
set /a indice+=1
if %numero% LEQ %indice% (
    goto reussi
) else goto echec
rem
:reussi
rem Cette boucle parcoure le fichier lorsque on arrive a la valeur de la variable numero on recupere le nom du point d'accees
for /f "tokens=1 delims=:" %%a in ('type numero.txt') do (
    set /a nb_ligne+=1
    if !nb_ligne!==!numero! (
        set nom=%%a
    )
)

netsh wlan show profiles "!nom!" key=clear > temporaire.txt    
set reponse_pointaccees=true

rem Boucle sur le fichier si la valeur Absent est trouver dans la boucle on modifie la valeur de la variable reponse_pointaccees
for /f "tokens=1,2 delims=:" %%a in ('type temporaire.txt ^| findstr /c:Absent') do (
    set reponse_pointaccees=false
)    

if %reponse_pointaccees%==true (
    goto avec_cle
) else goto sans_cle

rem Etiquette executer a si l utilisateur saisie un numero non compris dans le menu
:echec
del numero.txt
echo.
echo            Le numero que vous avez tapez n est pas compris dans le menu !!!
echo.
pause
goto recommencer

rem Etiquette executer si le point d accees ne contiient pas de cle de securiter
:sans_cle
echo.
echo.
del temporaire.txt
del numero.txt
echo                                      Votre point d'accees ne contient pas de cle de securiter
goto final1

rem Etiquette executer si le point d accees contient une cle de securiter
:avec_cle
rem Cette boucle va dans le fichier directement a la ligne qui contient la chaine "contenue" et recupere le code(la clé) du point d'accees
rem Boucle sur le fichier avec la recherche FINDSTR pour recupere la cle wifi
for /f "tokens=1,2 delims=:" %%a in ('type temporaire.txt ^| findstr Contenu') do (
    set code=%%b
)  
del temporaire.txt
echo.
echo.
echo.
echo.
rem Cette condition verifie que la valeur de la variable "code" est egale à false sa valeur de depart
if %code% EQU false (
    goto erreur 
)
rem Cette condition verifie que la valeur de la variable "code" n'est pas egale à false sa valeur de depart
if %code% NEQ false (
    goto contient
)

rem Etiquette est executer si la recherche de la cle a echouer
:erreur
echo                                 Pour une raison inconnu la cle de votre modem na pas pu etre trouver !
goto final1

rem Etiquette executer si la cle est trouver
:contient
cls
echo.
echo.
echo.
echo.
echo                                 La cle du point d accees [!nom!]  est [!code!]
echo.
echo.
echo.
echo.
echo                                 Voici quelques options supplementaire !!!
echo.
echo.
echo                          1 : Enregistrer le point d accees et sa cle selectionnez dans un fichier texte
echo.
echo                          2 : Enregistrer tous les points d accees et leur cle dans un fichier texte
echo.
echo                          3 : Quitter le programme
echo.
echo.
set /p reponse_option=              Saisissez le numero de l options que vous voulez appliquez :
if %reponse_option%==1 (
    goto optionun
)
if %reponse_option%==2 (
    goto optiondeux
)
if %reponse_option%==3 (
    echo.
    echo Appuyer sur n importe quelle touche pour quitter le programme !!!
    echo.
    goto final1
)
if %reponse_option% GTR 3 (
    goto contient
)

rem Etiquette est executer si l utilisateur saisie la premiere option
:optionun
del numero.txt
rem
if Not exist "Dossier contenant les points d accees" (
    md "Dossier contenant les points d accees"
)
echo                                                        La cle du point d accees [%nom%] est : %code%  > "Dossier contenant les points d accees\Cle du point d accees %nom%.txt"
echo.
echo                                                        Appuyer sur n importe quelle touche pour quitter le programme !!!
goto final1

rem Etiquette est executer si l utilisateur saisie la deuxieme option
:optiondeux
echo                                                Nom  :  Cle de securiter >> "Dictionnaire points d accees.txt"
echo.
echo.
echo                               Veuillez attendre pendant que le programme sauvegarde tous les points d accees avec leur cle ...
set nb_point_accees_valide=0
set /a indice-=1
rem Boucle allant de 0 jusqu a la valeur contenue par la variable indice
for /L %%i in (0,1,%indice%) do (
    set /a nb_ligne=%%i+1
    set numero=0
    rem Boucle sur le fichier lorsque le numero est egale a nb_ligne on recupere le nom du point d accees
    for /f "tokens=1 delims=:" %%a in ('type numero.txt') do (
        set /a numero+=1
        if !numero!==!nb_ligne! (
            set nom=%%a
        )
    )
    netsh wlan show profiles "!nom!" key=clear > temporaire.txt
    set reponse_pointaccees=true
    rem Boucle sur le fichier teste si le point d accees est en ouvert ou contient une cle
    for /f "tokens=1,2 delims=:" %%a in ('type temporaire.txt ^| findstr /c:Absent') do (
        set reponse_pointaccees=false
    )    
    if !reponse_pointaccees!==true (
        rem Boucle sur le fichier utilisant la recherche FINDSTR on recupere le code wifi
        for /f "tokens=1,2 delims=:" %%a in ('type temporaire.txt ^| findstr Contenu') do (
            set code=%%b
        )
        rem compte les points d accees qui contienne une cle
        set /a nb_point_accees_valide+=1
        echo                                                !nom!  :  !code! >> "Dictionnaire points d accees.txt"
    )
    
)
del temporaire.txt
del numero.txt
echo.
echo                                                    !nb_point_accees_valide! points d accees ont ete sauvegarder dans le fichier !!!
echo.
echo                                                Les points d accees n ayant pas de cle de securiter ont ete ignorer
goto final1


rem
:final1
pause > null
del null.*
exit

endlocal