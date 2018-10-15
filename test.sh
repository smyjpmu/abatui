# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements

COUNTRY=$(whiptail --radiolist "select=[space], continue=[enter]" 40 60 30 --title "country" 3>&1 1>&2 2>&3 AD Andorra OFF AE United\ Arab\ Emirates OFF AF Afghanistan OFF AG Antigua\ and\ Barbuda OFF AI Anguilla OFF AL Albania OFF AM Armenia OFF AO Angola OFF AQ Antartica OFF AR Argentina OFF AS American\ Samoa OFF AT Austria OFF AU Australia OFF AW Aruba OFF AX Åland\ Islands OFF AZ Azerbaijan OFF BA Bosnia\ and\ Herzegovina OFF BB Bangladesh OFF BE Belgium OFF BF Burkina\ Faso OFF BG Bulgaria OFF BH Bahrain OFF BI Burundi OFF BJ Benin OFF BL Saint\ Barhtélemy OFF BM Bermuda OFF BN Brunei\ Darussalam OFF BO Bolivia OFF BQ Bonaire,\ Sint\ &\ Saba OFF BR Brazil OFF BS Bahamas OFF BT Bhutan OFF BV Bouvet\ Island OFF BW Botswana OFF BY Belarus OFF BZ Belize OFF CA Canada ON CC Cocos\ Islands OFF CD Democratic\ Republic\ of\ the\ Congo OFF CF Central\ African\ Republic OFF CG Congo OFF CH Switzerland OFF CI Côte\ d\'Ivoire OFF CK Cook\ Islands OFF CL Chile OFF CM Cameroon OFF CN China OFF CO Colombia CR Costa\ Rica OFF CU Cuba OFF CV Cabo\ Verde OFF CW Curaçao OFF CX Christmas\ Island OFF CY Cyprus OFF CZ Czechia OFF DE Germany OFF DJ DJibouti OFF DK Denmark OFF DM Dominica OFF DO Dominican\ Republic OFF DZ Algeria OFF EC Ecuador OFF EE Estonia OFF EG Egypt OFF EH Western\ Sahara OFF ER Eritrea OFF ES Spain OFF

echo $COUNTRY


SAVED==$(whiptail --menu "select=[ENTER]" 40 60 30 --title "true/false" 3>&1 1>&2 2>&3 \
	"false" "I haven't saved" "true" "I have saved")

if [ "$SAVED" = "true" ]; then
	shutdown now
else
	exit
fi

