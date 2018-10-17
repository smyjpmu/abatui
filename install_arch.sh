#!/bin/bash

	GNUGPL="\
#    this script is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    this script is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this script.  If not, see <https://www.gnu.org/licenses/>.
"

# GNU G.P.L
	whiptail --msgbox "$GNUGPL" --title "GNU General Public License" 18 78

# Target drive
	LSBLK="$(lsblk)"
	TARGET_DRIVE=$(whiptail --inputbox "/dev/sd* (replace the * with the drive letter no number) $LSBLK" 15 60 /dev/ --title "target drive" 3>&1 1>&2 2>&3)

# Bootloader ID
	BOOTLOADER_ID=$(whiptail --inputbox "done=[ENTER], write the bootloader ID." 8 60 Arch --title "bootloader id" 3>&1 1>&2 2>&3)

# Hostname
	HOSTNAME=$(whiptail --inputbox "done=[ENTER], write the hostname (PC name)." 8 60 archlinux --title "hostname" 3>&1 1>&2 2>&3)

# Username
	USERNAME=$(whiptail --inputbox "done=[ENTER], write your username." 8 60 noname --title "username" 3>&1 1>&2 2>&3)

# Password
	PASSWORD=$(whiptail --passwordbox "done=[ENTER], enter the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
	PASSWORD2=$(whiptail --passwordbox "done=[ENTER], re-enter the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
	if [ "$PASSWORD" != "$PASSWORD2" ]; then
		whiptail --msgbox "Passowrds did not match, please try again. (2 tries left)" --title "failed password" 8 60
		PASSWORD=$(whiptail --passwordbox "done=[ENTER], write the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
		PASSWORD2=$(whiptail --passwordbox "done=[ENTER], write the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
		if [ "$PASSWORD" != "$PASSWORD2" ]; then
			whiptail --msgbox "Passowrds did not match, please try again. (last try)" --title "failed password" 8 60
			PASSWORD=$(whiptail --passwordbox "done=[ENTER], write the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
			PASSWORD2=$(whiptail --passwordbox "done=[ENTER], write the password for user." 8 60 --title "password for user" 3>&1 1>&2 2>&3)
			if [ "$PASSWORD" != "$PASSWORD2" ]; then
				exit
			fi
		fi
	fi

# Interface
	INTERFACE=$(whiptail --menu "select=[ENTER]" 18 80 10 --title "interface" 3>&1 1>&2 2>&3 "NODEORWM" "Comes with nothing and is nothing." "BUDGIE" "Modern design, focuses on simplicity and elegance." "CINNAMON" "Strives to provide a traditional user experience." "GNOME" "An attractive and intuitive desktop." "KDE" "Modern and familiar working environment." "LXDE" "Strives to be less CPU and RAM intensive." "LXQT" "Lightweight, modular, blazing-fast and user-friendly." "MATE" " Intuitive and attractive desktop using traditional metaphors." "XFCE" "Traditional UNIX philosophy of modularity and re-usability." "I3WM" "Primarily targeted at developers and advanced users")

# Display manager
	DISPLAYMANAGER=$(whiptail --menu "select=[ENTER]" 12 50 5 --title "display manager" 3>&1 1>&2 2>&3 "nodm" "Comes with nothing and is nothing." "gdm" "Recommended for Budgie & Gnome." "lightdm" "Recommended for XFCE." "lxdm" "Recommended for LXDE." "sddm" "Recommended for KDE & LXQT.")

# Custom packages
	CUSTOM_PACKAGES=$(whiptail --separate-output --checklist "select=[space], done=[enter]" 30 50 22 --title "custom packages" 3>&1 1>&2 2>&3 "unzip" "Unzip" ON "p7zip" "P7zip" ON "unrar" "Unrar" ON "curl" "Curl" ON "wget" "Wget" ON "pulseaudio" "Sound Server" ON "git" "Git" ON "powerline-fonts" "Fonts" ON "firefox" "Web Browser" ON "vlc" "Multimedia Player" ON "zsh" "Z Shell" ON)

# Other custom packages
	OTHER_CUSTOM_PACKAGES=$(whiptail --inputbox "done=[ENTER]" 8 60 --title "other custom packages" 3>&1 1>&2 2>&3)

# Nvme drive
	NVME=$(whiptail --menu "select=[ENTER], default=(false)" 8 60 2 --title "nvme" 3>&1 1>&2 2>&3 "false" "I don't have an Nvme SSD." "true" "I have an Nvme SSD.")

# Encrypt drive
	ENCRYPT_DRIVE=$(whiptail --menu "select=[ENTER], default=(false)" 8 60 2 --title "drive encryption" 3>&1 1>&2 2>&3 "false" "I don't want to encrypt my drive." "true" "I want to encrypt my drive.")

# Timezone
	TIMEZONE=""
	CHOOSING_TIMEZONE=true
    while [ $CHOOSING_TIMEZONE ]; do
        if [ -d "/usr/share/zoneinfo"$(if [ -n $TIMEZONE ]; then echo "/$TIMEZONE/"; fi) ]; then
             TMP_TIMEZONE=$(whiptail --noitem --title "timezone" --menu "select/continue=[enter]" 30 40 22 $(for ZONE in $(find /usr/share/zoneinfo/$(if [ -n "$TIMEZONE" ]; then echo "$TIMEZONE/"; fi) -maxdepth 1 \
             $([ -z "$TIMEZONE" ] && echo "-type d") -not -name right -not -name posix -not -name Etc -not -wholename "/usr/share/zoneinfo/$TIMEZONE/" -not -wholename "/usr/share/zoneinfo/$TIMEZONE" 2>/dev/null | sed "s#/usr/share/zoneinfo/$TIMEZONE##" | sed "s#/##"); do
                 echo "$ZONE $ZONE"
             done) 3>&1 1>&2 2>&3)
             if [ -z $TIMEZONE ]; then
                 TIMEZONE="$TMP_TIMEZONE"
             else
                 TIMEZONE=$TIMEZONE/$TMP_TIMEZONE
             fi
        else
            CHOOSING_TIMEZONE=false
            break
        fi
     done

# Locale
	LOCALE=$(whiptail --radiolist "select=[space], continue=[enter]. default=en_US.UTF-8 UTF-8" 40 60 30 --title "locale" 3>&1 1>&2 2>&3 "aa_DJ.UTF-8 UTF-8" "locale" OFF "aa_DJ ISO-8859-1" "locale" OFF "aa_ER UTF-8" "locale" OFF "aa_ER@saaho UTF-8" "locale" OFF "aa_ET UTF-8" "locale" OFF "af_ZA.UTF-8 UTF-8" "locale" OFF "af_ZA ISO-8859-1" "locale" OFF "agr_PE UTF-8" "locale" OFF "ak_GH UTF-8" "locale" OFF "am_ET UTF-8" "locale" OFF "an_ES.UTF-8 UTF-8" "locale" OFF "an_ES ISO-8859-15" "locale" OFF "anp_IN UTF-8" "locale" OFF "ar_AE.UTF-8 UTF-8" "locale" OFF "ar_AE ISO-8859-6" "locale" OFF "ar_BH.UTF-8 UTF-8" "locale" OFF "ar_BH ISO-8859-6" "locale" OFF "ar_DZ.UTF-8 UTF-8" "locale" OFF "ar_DZ ISO-8859-6" "locale" OFF "ar_EG.UTF-8 UTF-8" "locale" OFF "ar_EG ISO-8859-6" "locale" OFF "ar_IN UTF-8" "locale" OFF "ar_IQ.UTF-8 UTF-8" "locale" OFF "ar_IQ ISO-8859-6" "locale" OFF "ar_JO.UTF-8 UTF-8" "locale" OFF "ar_JO ISO-8859-6" "locale" OFF "ar_KW.UTF-8 UTF-8" "locale" OFF "ar_KW ISO-8859-6" "locale" OFF "ar_LB.UTF-8 UTF-8" "locale" OFF "ar_LB ISO-8859-6" "locale" OFF "ar_LY.UTF-8 UTF-8" "locale" OFF "ar_LY ISO-8859-6" "locale" OFF "ar_MA.UTF-8 UTF-8" "locale" OFF "ar_MA ISO-8859-6" "locale" OFF "ar_OM.UTF-8 UTF-8" "locale" OFF "ar_OM ISO-8859-6" "locale" OFF "ar_QA.UTF-8 UTF-8" "locale" OFF "ar_QA ISO-8859-6" "locale" OFF "ar_SA.UTF-8 UTF-8" "locale" OFF "ar_SA ISO-8859-6" "locale" OFF "ar_SD.UTF-8 UTF-8" "locale" OFF "ar_SD ISO-8859-6" "locale" OFF "ar_SS UTF-8" "locale" OFF "ar_SY.UTF-8 UTF-8" "locale" OFF "ar_SY ISO-8859-6" "locale" OFF "ar_TN.UTF-8 UTF-8" "locale" OFF "ar_TN ISO-8859-6" "locale" OFF "ar_YE.UTF-8 UTF-8" "locale" OFF "ar_YE ISO-8859-6" "locale" OFF "ayc_PE UTF-8" "locale" OFF "az_AZ UTF-8" "locale" OFF "az_IR UTF-8" "locale" OFF "as_IN UTF-8" "locale" OFF "ast_ES.UTF-8 UTF-8" "locale" OFF "ast_ES ISO-8859-15" "locale" OFF "be_BY.UTF-8 UTF-8" "locale" OFF "be_BY CP1251" "locale" OFF "be_BY@latin UTF-8" "locale" OFF "bem_ZM UTF-8" "locale" OFF "ber_DZ UTF-8" "locale" OFF "ber_MA UTF-8" "locale" OFF "bg_BG.UTF-8 UTF-8" "locale" OFF "bg_BG CP1251" "locale" OFF "bhb_IN.UTF-8 UTF-8" "locale" OFF "bho_IN UTF-8" "locale" OFF "bho_NP UTF-8" "locale" OFF "bi_VU UTF-8" "locale" OFF "bn_BD UTF-8" "locale" OFF "bn_IN UTF-8" "locale" OFF "bo_CN UTF-8" "locale" OFF "bo_IN UTF-8" "locale" OFF "br_FR.UTF-8 UTF-8" "locale" OFF "br_FR ISO-8859-1" "locale" OFF "br_FR@euro ISO-8859-15" "locale" OFF "brx_IN UTF-8" "locale" OFF "bs_BA.UTF-8 UTF-8" "locale" OFF "bs_BA ISO-8859-2" "locale" OFF "byn_ER UTF-8" "locale" OFF "ca_AD.UTF-8 UTF-8" "locale" OFF "ca_AD ISO-8859-15" "locale" OFF "ca_ES.UTF-8 UTF-8" "locale" OFF "ca_ES ISO-8859-1" "locale" OFF "ca_ES@euro ISO-8859-15" "locale" OFF "ca_ES@valencia UTF-8" "locale" OFF "ca_FR.UTF-8 UTF-8" "locale" OFF "ca_FR ISO-8859-15" "locale" OFF "ca_IT.UTF-8 UTF-8" "locale" OFF "ca_IT ISO-8859-15" "locale" OFF "ce_RU UTF-8" "locale" OFF "chr_US UTF-8" "locale" OFF "cmn_TW UTF-8" "locale" OFF "crh_UA UTF-8" "locale" OFF "cs_CZ.UTF-8 UTF-8" "locale" OFF "cs_CZ ISO-8859-2" "locale" OFF "csb_PL UTF-8" "locale" OFF "cv_RU UTF-8" "locale" OFF "cy_GB.UTF-8 UTF-8" "locale" OFF "cy_GB ISO-8859-14" "locale" OFF "da_DK.UTF-8 UTF-8" "locale" OFF "da_DK ISO-8859-1" "locale" OFF "de_AT.UTF-8 UTF-8" "locale" OFF "de_AT ISO-8859-1" "locale" OFF "de_AT@euro ISO-8859-15" "locale" OFF "de_BE.UTF-8 UTF-8" "locale" OFF "de_BE ISO-8859-1" "locale" OFF "de_BE@euro ISO-8859-15" "locale" OFF "de_CH.UTF-8 UTF-8" "locale" OFF "de_CH ISO-8859-1" "locale" OFF "de_DE.UTF-8 UTF-8" "locale" OFF "de_DE ISO-8859-1" "locale" OFF "de_DE@euro ISO-8859-15" "locale" OFF "de_IT.UTF-8 UTF-8" "locale" OFF "de_IT ISO-8859-1" "locale" OFF "de_LI.UTF-8 UTF-8" "locale" OFF "de_LU.UTF-8 UTF-8" "locale" OFF "de_LU ISO-8859-1" "locale" OFF "de_LU@euro ISO-8859-15" "locale" OFF "doi_IN UTF-8" "locale" OFF "dsb_DE UTF-8" "locale" OFF "dv_MV UTF-8" "locale" OFF "dz_BT UTF-8" "locale" OFF "el_GR.UTF-8 UTF-8" "locale" OFF "el_GR ISO-8859-7" "locale" OFF "el_GR@euro ISO-8859-7" "locale" OFF "el_CY.UTF-8 UTF-8" "locale" OFF "el_CY ISO-8859-7" "locale" OFF "en_AG UTF-8" "locale" OFF "en_AU.UTF-8 UTF-8" "locale" OFF "en_AU ISO-8859-1" "locale" OFF "en_BW.UTF-8 UTF-8" "locale" OFF "en_BW ISO-8859-1" "locale" OFF "en_CA.UTF-8 UTF-8" "locale" OFF "en_CA ISO-8859-1" "locale" OFF "en_DK.UTF-8 UTF-8" "locale" OFF "en_DK ISO-8859-1" "locale" OFF "en_GB.UTF-8 UTF-8" "locale" OFF "en_GB ISO-8859-1" "locale" OFF "en_HK.UTF-8 UTF-8" "locale" OFF "en_HK ISO-8859-1" "locale" OFF "en_IE.UTF-8 UTF-8" "locale" OFF "en_IE ISO-8859-1" "locale" OFF "en_IE@euro ISO-8859-15" "locale" OFF "en_IL UTF-8" "locale" OFF "en_IN UTF-8" "locale" OFF "en_NG UTF-8" "locale" OFF "en_NZ.UTF-8 UTF-8" "locale" OFF "en_NZ ISO-8859-1" "locale" OFF "en_PH.UTF-8 UTF-8" "locale" OFF "en_PH ISO-8859-1" "locale" OFF "en_SC.UTF-8 UTF-8" "locale" OFF "en_SG.UTF-8 UTF-8" "locale" OFF "en_SG ISO-8859-1" "locale" OFF "en_US.UTF-8 UTF-8" "locale" ON "en_US ISO-8859-1" "locale" OFF "en_ZA.UTF-8 UTF-8" "locale" OFF "en_ZA ISO-8859-1" "locale" OFF "en_ZM UTF-8" "locale" OFF "en_ZW.UTF-8 UTF-8" "locale" OFF "en_ZW ISO-8859-1" "locale" OFF "eo UTF-8" "locale" OFF "es_AR.UTF-8 UTF-8" "locale" OFF "es_AR ISO-8859-1" "locale" OFF "es_BO.UTF-8 UTF-8" "locale" OFF "es_BO ISO-8859-1" "locale" OFF "es_CL.UTF-8 UTF-8" "locale" OFF "es_CL ISO-8859-1" "locale" OFF "es_CO.UTF-8 UTF-8" "locale" OFF "es_CO ISO-8859-1" "locale" OFF "es_CR.UTF-8 UTF-8" "locale" OFF "es_CR ISO-8859-1" "locale" OFF "es_CU UTF-8" "locale" OFF "es_DO.UTF-8 UTF-8" "locale" OFF "es_DO ISO-8859-1" "locale" OFF "es_EC.UTF-8 UTF-8" "locale" OFF "es_EC ISO-8859-1" "locale" OFF "es_ES.UTF-8 UTF-8" "locale" OFF "es_ES ISO-8859-1" "locale" OFF "es_ES@euro ISO-8859-15" "locale" OFF "es_GT.UTF-8 UTF-8" "locale" OFF "es_GT ISO-8859-1" "locale" OFF "es_HN.UTF-8 UTF-8" "locale" OFF "es_HN ISO-8859-1" "locale" OFF "es_MX.UTF-8 UTF-8" "locale" OFF "es_MX ISO-8859-1" "locale" OFF "es_NI.UTF-8 UTF-8" "locale" OFF "es_NI ISO-8859-1" "locale" OFF "es_PA.UTF-8 UTF-8" "locale" OFF "es_PA ISO-8859-1" "locale" OFF "es_PE.UTF-8 UTF-8" "locale" OFF "es_PE ISO-8859-1" "locale" OFF "es_PR.UTF-8 UTF-8" "locale" OFF "es_PR ISO-8859-1" "locale" OFF "es_PY.UTF-8 UTF-8" "locale" OFF "es_PY ISO-8859-1" "locale" OFF "es_SV.UTF-8 UTF-8" "locale" OFF "es_SV ISO-8859-1" "locale" OFF "es_US.UTF-8 UTF-8" "locale" OFF "es_US ISO-8859-1" "locale" OFF "es_UY.UTF-8 UTF-8" "locale" OFF "es_UY ISO-8859-1" "locale" OFF "es_VE.UTF-8 UTF-8" "locale" OFF "es_VE ISO-8859-1" "locale" OFF "et_EE.UTF-8 UTF-8" "locale" OFF "et_EE ISO-8859-1" "locale" OFF "et_EE.ISO-8859-15 ISO-8859-15" "locale" OFF "eu_ES.UTF-8 UTF-8" "locale" OFF "eu_ES ISO-8859-1" "locale" OFF "eu_ES@euro ISO-8859-15" "locale" OFF "fa_IR UTF-8" "locale" OFF "ff_SN UTF-8" "locale" OFF "fi_FI.UTF-8 UTF-8" "locale" OFF "fi_FI ISO-8859-1" "locale" OFF "fi_FI@euro ISO-8859-15" "locale" OFF "fil_PH UTF-8" "locale" OFF "fo_FO.UTF-8 UTF-8" "locale" OFF "fo_FO ISO-8859-1" "locale" OFF "fr_BE.UTF-8 UTF-8" "locale" OFF "fr_BE ISO-8859-1" "locale" OFF "fr_BE@euro ISO-8859-15" "locale" OFF "fr_CA.UTF-8 UTF-8" "locale" OFF "fr_CA ISO-8859-1" "locale" OFF "fr_CH.UTF-8 UTF-8" "locale" OFF "fr_CH ISO-8859-1" "locale" OFF "fr_FR.UTF-8 UTF-8" "locale" OFF "fr_FR ISO-8859-1" "locale" OFF "fr_FR@euro ISO-8859-15" "locale" OFF "fr_LU.UTF-8 UTF-8" "locale" OFF "fr_LU ISO-8859-1" "locale" OFF "fr_LU@euro ISO-8859-15" "locale" OFF "fur_IT UTF-8" "locale" OFF "fy_NL UTF-8" "locale" OFF "fy_DE UTF-8" "locale" OFF "ga_IE.UTF-8 UTF-8" "locale" OFF "ga_IE ISO-8859-1" "locale" OFF "ga_IE@euro ISO-8859-15" "locale" OFF "gd_GB.UTF-8 UTF-8" "locale" OFF "gd_GB ISO-8859-15" "locale" OFF "gez_ER UTF-8" "locale" OFF "gez_ER@abegede UTF-8" "locale" OFF "gez_ET UTF-8" "locale" OFF "gez_ET@abegede UTF-8" "locale" OFF "gl_ES.UTF-8 UTF-8" "locale" OFF "gl_ES ISO-8859-1" "locale" OFF "gl_ES@euro ISO-8859-15" "locale" OFF "gu_IN UTF-8" "locale" OFF "gv_GB.UTF-8 UTF-8" "locale" OFF "gv_GB ISO-8859-1" "locale" OFF "ha_NG UTF-8" "locale" OFF "hak_TW UTF-8" "locale" OFF "he_IL.UTF-8 UTF-8" "locale" OFF "he_IL ISO-8859-8" "locale" OFF "hi_IN UTF-8" "locale" OFF "hif_FJ UTF-8" "locale" OFF "hne_IN UTF-8" "locale" OFF "hr_HR.UTF-8 UTF-8" "locale" OFF "hr_HR ISO-8859-2" "locale" OFF "hsb_DE ISO-8859-2" "locale" OFF "hsb_DE.UTF-8 UTF-8" "locale" OFF "ht_HT UTF-8" "locale" OFF "hu_HU.UTF-8 UTF-8" "locale" OFF "hu_HU ISO-8859-2" "locale" OFF "hy_AM UTF-8" "locale" OFF "hy_AM.ARMSCII-8 ARMSCII-8" "locale" OFF "ia_FR UTF-8" "locale" OFF "id_ID.UTF-8 UTF-8" "locale" OFF "id_ID ISO-8859-1" "locale" OFF "ig_NG UTF-8" "locale" OFF "ik_CA UTF-8" "locale" OFF "is_IS.UTF-8 UTF-8" "locale" OFF "is_IS ISO-8859-1" "locale" OFF "it_CH.UTF-8 UTF-8" "locale" OFF "it_CH ISO-8859-1" "locale" OFF "it_IT.UTF-8 UTF-8" "locale" OFF "it_IT ISO-8859-1" "locale" OFF "it_IT@euro ISO-8859-15" "locale" OFF "iu_CA UTF-8" "locale" OFF "ja_JP.EUC-JP EUC-JP" "locale" OFF "ja_JP.UTF-8 UTF-8" "locale" OFF "ka_GE.UTF-8 UTF-8" "locale" OFF "ka_GE GEORGIAN-PS" "locale" OFF "kab_DZ UTF-8" "locale" OFF "kk_KZ.UTF-8 UTF-8" "locale" OFF "kk_KZ PT154" "locale" OFF "kl_GL.UTF-8 UTF-8" "locale" OFF "kl_GL ISO-8859-1" "locale" OFF "km_KH UTF-8" "locale" OFF "kn_IN UTF-8" "locale" OFF "ko_KR.EUC-KR EUC-KR" "locale" OFF "ko_KR.UTF-8 UTF-8" "locale" OFF "kok_IN UTF-8" "locale" OFF "ks_IN UTF-8" "locale" OFF "ks_IN@devanagari UTF-8" "locale" OFF "ku_TR.UTF-8 UTF-8" "locale" OFF "ku_TR ISO-8859-9" "locale" OFF "kw_GB.UTF-8 UTF-8" "locale" OFF "kw_GB ISO-8859-1" "locale" OFF "ky_KG UTF-8" "locale" OFF "lb_LU UTF-8" "locale" OFF "lg_UG.UTF-8 UTF-8" "locale" OFF "lg_UG ISO-8859-10" "locale" OFF "li_BE UTF-8" "locale" OFF "li_NL UTF-8" "locale" OFF "lij_IT UTF-8" "locale" OFF "ln_CD UTF-8" "locale" OFF "lo_LA UTF-8" "locale" OFF "lt_LT.UTF-8 UTF-8" "locale" OFF "lt_LT ISO-8859-13" "locale" OFF "lv_LV.UTF-8 UTF-8" "locale" OFF "lv_LV ISO-8859-13" "locale" OFF "lzh_TW UTF-8" "locale" OFF "mag_IN UTF-8" "locale" OFF "mai_IN UTF-8" "locale" OFF "mai_NP UTF-8" "locale" OFF "mfe_MU UTF-8" "locale" OFF "mg_MG.UTF-8 UTF-8" "locale" OFF "mg_MG ISO-8859-15" "locale" OFF "mhr_RU UTF-8" "locale" OFF "mi_NZ.UTF-8 UTF-8" "locale" OFF "mi_NZ ISO-8859-13" "locale" OFF "miq_NI UTF-8" "locale" OFF "mjw_IN UTF-8" "locale" OFF "mk_MK.UTF-8 UTF-8" "locale" OFF "mk_MK ISO-8859-5" "locale" OFF "ml_IN UTF-8" "locale" OFF "mn_MN UTF-8" "locale" OFF "mni_IN UTF-8" "locale" OFF "mr_IN UTF-8" "locale" OFF "ms_MY.UTF-8 UTF-8" "locale" OFF "ms_MY ISO-8859-1" "locale" OFF "mt_MT.UTF-8 UTF-8" "locale" OFF "mt_MT ISO-8859-3" "locale" OFF "my_MM UTF-8" "locale" OFF "nan_TW UTF-8" "locale" OFF "nan_TW@latin UTF-8" "locale" OFF "nb_NO.UTF-8 UTF-8" "locale" OFF "nb_NO ISO-8859-1" "locale" OFF "nds_DE UTF-8" "locale" OFF "nds_NL UTF-8" "locale" OFF "ne_NP UTF-8" "locale" OFF "nhn_MX UTF-8" "locale" OFF "niu_NU UTF-8" "locale" OFF "niu_NZ UTF-8" "locale" OFF "nl_AW UTF-8" "locale" OFF "nl_BE.UTF-8 UTF-8" "locale" OFF "nl_BE ISO-8859-1" "locale" OFF "nl_BE@euro ISO-8859-15" "locale" OFF "nl_NL.UTF-8 UTF-8" "locale" OFF "nl_NL ISO-8859-1" "locale" OFF "nl_NL@euro ISO-8859-15" "locale" OFF "nn_NO.UTF-8 UTF-8" "locale" OFF "nn_NO ISO-8859-1" "locale" OFF "nr_ZA UTF-8" "locale" OFF "nso_ZA UTF-8" "locale" OFF "oc_FR.UTF-8 UTF-8" "locale" OFF "oc_FR ISO-8859-1" "locale" OFF "om_ET UTF-8" "locale" OFF "om_KE ISO-8859-1" "locale" OFF "om_KE.UTF-8 UTF-8" "locale" OFF "or_IN UTF-8" "locale" OFF "os_RU UTF-8" "locale" OFF "pa_IN UTF-8" "locale" OFF "pa_PK UTF-8" "locale" OFF "pap_AW UTF-8" "locale" OFF "pap_CW UTF-8" "locale" OFF "pl_PL.UTF-8 UTF-8" "locale" OFF "pl_PL ISO-8859-2" "locale" OFF "ps_AF UTF-8" "locale" OFF "pt_BR.UTF-8 UTF-8" "locale" OFF "pt_BR ISO-8859-1" "locale" OFF "pt_PT.UTF-8 UTF-8" "locale" OFF "pt_PT ISO-8859-1" "locale" OFF "pt_PT@euro ISO-8859-15" "locale" OFF "quz_PE UTF-8" "locale" OFF "raj_IN UTF-8" "locale" OFF "ro_RO.UTF-8 UTF-8" "locale" OFF "ro_RO ISO-8859-2" "locale" OFF "ru_RU.KOI8-R KOI8-R" "locale" OFF "ru_RU.UTF-8 UTF-8" "locale" OFF "ru_RU ISO-8859-5" "locale" OFF "ru_UA.UTF-8 UTF-8" "locale" OFF "ru_UA KOI8-U" "locale" OFF "sa_IN UTF-8" "locale" OFF "rw_RW UTF-8" "locale" OFF "sah_RU UTF-8" "locale" OFF "sat_IN UTF-8" "locale" OFF "sc_IT UTF-8" "locale" OFF "sd_IN UTF-8" "locale" OFF "sd_IN@devanagari UTF-8" "locale" OFF "se_NO UTF-8" "locale" OFF "sgs_LT UTF-8" "locale" OFF "shn_MM UTF-8" "locale" OFF "shs_CA UTF-8" "locale" OFF "si_LK UTF-8" "locale" OFF "sid_ET UTF-8" "locale" OFF "sk_SK.UTF-8 UTF-8" "locale" OFF "sk_SK ISO-8859-2" "locale" OFF "sl_SI.UTF-8 UTF-8" "locale" OFF "sl_SI ISO-8859-2" "locale" OFF "sm_WS UTF-8" "locale" OFF "so_DJ.UTF-8 UTF-8" "locale" OFF "so_DJ ISO-8859-1" "locale" OFF "so_ET UTF-8" "locale" OFF "so_KE ISO-8859-1" "locale" OFF "so_KE.UTF-8 UTF-8" "locale" OFF "so_SO.UTF-8 UTF-8" "locale" OFF "so_SO ISO-8859-1" "locale" OFF "sq_AL.UTF-8 UTF-8" "locale" OFF "sq_AL ISO-8859-1" "locale" OFF "sq_MK UTF-8" "locale" OFF "sr_ME UTF-8" "locale" OFF "sr_RS UTF-8" "locale" OFF "sr_RS@latin UTF-8" "locale" OFF "ss_ZA UTF-8" "locale" OFF "st_ZA.UTF-8 UTF-8" "locale" OFF "st_ZA ISO-8859-1" "locale" OFF "sv_FI.UTF-8 UTF-8" "locale" OFF "sv_FI ISO-8859-1" "locale" OFF "sv_FI@euro ISO-8859-15" "locale" OFF "sv_SE.UTF-8 UTF-8" "locale" OFF "sv_SE ISO-8859-1" "locale" OFF "sw_KE UTF-8" "locale" OFF "sw_TZ UTF-8" "locale" OFF "szl_PL UTF-8" "locale" OFF "ta_IN UTF-8" "locale" OFF "ta_LK UTF-8" "locale" OFF "tcy_IN.UTF-8 UTF-8" "locale" OFF "te_IN UTF-8" "locale" OFF "tg_TJ.UTF-8 UTF-8" "locale" OFF "tg_TJ KOI8-T" "locale" OFF "th_TH.UTF-8 UTF-8" "locale" OFF "th_TH TIS-620" "locale" OFF "the_NP UTF-8" "locale" OFF "ti_ER UTF-8" "locale" OFF "ti_ET UTF-8" "locale" OFF "tig_ER UTF-8" "locale" OFF "tk_TM UTF-8" "locale" OFF "tl_PH.UTF-8 UTF-8" "locale" OFF "tl_PH ISO-8859-1" "locale" OFF "tn_ZA UTF-8" "locale" OFF "to_TO UTF-8" "locale" OFF "tpi_PG UTF-8" "locale" OFF "tr_CY.UTF-8 UTF-8" "locale" OFF "tr_CY ISO-8859-9" "locale" OFF "tr_TR.UTF-8 UTF-8" "locale" OFF "tr_TR ISO-8859-9" "locale" OFF "ts_ZA UTF-8" "locale" OFF "tt_RU UTF-8" "locale" OFF "tt_RU@iqtelif UTF-8" "locale" OFF "ug_CN UTF-8" "locale" OFF "uk_UA.UTF-8 UTF-8" "locale" OFF "uk_UA KOI8-U" "locale" OFF "unm_US UTF-8" "locale" OFF "ur_IN UTF-8" "locale" OFF "ur_PK UTF-8" "locale" OFF "uz_UZ.UTF-8 UTF-8" "locale" OFF "uz_UZ ISO-8859-1" "locale" OFF "uz_UZ@cyrillic UTF-8" "locale" OFF "ve_ZA UTF-8" "locale" OFF "vi_VN UTF-8" "locale" OFF "wa_BE ISO-8859-1" "locale" OFF "wa_BE@euro ISO-8859-15" "locale" OFF "wa_BE.UTF-8 UTF-8" "locale" OFF "wae_CH UTF-8" "locale" OFF "wal_ET UTF-8" "locale" OFF "wo_SN UTF-8" "locale" OFF "xh_ZA.UTF-8 UTF-8" "locale" OFF "xh_ZA ISO-8859-1" "locale" OFF "yi_US.UTF-8 UTF-8" "locale" OFF "yi_US CP1255" "locale" OFF "yo_NG UTF-8" "locale" OFF "yue_HK UTF-8" "locale" OFF "yuw_PG UTF-8" "locale" OFF "zh_CN.GB18030 GB18030" "locale" OFF "zh_CN.GBK GBK" "locale" OFF "zh_CN.UTF-8 UTF-8" "locale" OFF "zh_CN GB2312" "locale" OFF "zh_HK.UTF-8 UTF-8" "locale" OFF "zh_HK BIG5-HKSCS" "locale" OFF "zh_SG.UTF-8 UTF-8" "locale" OFF "zh_SG.GBK GBK" "locale" OFF "zh_SG GB2312" "locale" OFF "zh_TW.EUC-TW EUC-TW" "locale" OFF "zh_TW.UTF-8 UTF-8" "locale" OFF "zh_TW BIG5" "locale" OFF "zu_ZA.UTF-8 UTF-8" "locale" OFF "zu_ZA ISO-8859-1" "locale" OFF)

# Keymap
	KEYMAP=$(whiptail --radiolist "select=[space], continue=[enter]. default=us" 40 60 30 --title "keymap" 3>&1 1>&2 2>&3 "ANSI-dvorak" "keymap" OFF "amiga-de" "keymap" OFF "amiga-us" "keymap" OFF "applkey" "keymap" OFF "atari-de" "keymap" OFF "atari-se" "keymap" OFF "atari-uk-falcon" "keymap" OFF "atari-us" "keymap" OFF "azerty" "keymap" OFF "backspace" "keymap" OFF "bashkir" "keymap" OFF "be-latin1" "keymap" OFF "bg-cp1251" "keymap" OFF "bg-cp855" "keymap" OFF "bg_bds-cp1251" "keymap" OFF "bg_bds-utf8" "keymap" OFF "bg_pho-cp1251" "keymap" OFF "bg_pho-utf8" "keymap" OFF "br-abnt" "keymap" OFF "br-abnt2" "keymap" OFF "br-latin1-abnt2" "keymap" OFF "br-latin1-us" "keymap" OFF "by" "keymap" OFF "by-cp1251" "keymap" OFF "bywin-cp1251" "keymap" OFF "carpalx" "keymap" OFF "carpalx-full" "keymap" OFF "cf" "keymap" OFF "colemak" "keymap" OFF "croat" "keymap" OFF "ctrl" "keymap" OFF "cz" "keymap" OFF "cz-cp1250" "keymap" OFF "cz-lat2" "keymap" OFF "cz-lat2-prog" "keymap" OFF "cz-qwertz" "keymap" OFF "cz-us-qwertz" "keymap" OFF "de" "keymap" OFF "de-latin1" "keymap" OFF "de-latin1-nodeadkeys" "keymap" OFF "de-mobii" "keymap" OFF "de_CH-latin1" "keymap" OFF "de_alt_UTF-8" "keymap" OFF "defkeymap" "keymap" OFF "defkeymap_V1.0" "keymap" OFF "dk" "keymap" OFF "dk-latin1" "keymap" OFF "dvorak" "keymap" OFF "dvorak-ca-fr" "keymap" OFF "dvorak-es" "keymap" OFF "dvorak-fr" "keymap" OFF "dvorak-l" "keymap" OFF "dvorak-la" "keymap" OFF "dvorak-programmer" "keymap" OFF "dvorak-r" "keymap" OFF "dvorak-ru" "keymap" OFF "dvorak-sv-a1" "keymap" OFF "dvorak-sv-a5" "keymap" OFF "dvorak-uk" "keymap" OFF "emacs" "keymap" OFF "emacs2" "keymap" OFF "es" "keymap" OFF "es-cp850" "keymap" OFF "es-olpc" "keymap" OFF "et" "keymap" OFF "et-nodeadkeys" "keymap" OFF "euro" "keymap" OFF "euro1" "keymap" OFF "euro2" "keymap" OFF "fi" "keymap" OFF "fr" "keymap" OFF "fr-bepo" "keymap" OFF "fr-bepo-latin9" "keymap" OFF "fr-latin1" "keymap" OFF "fr-latin9" "keymap" OFF "fr-pc" "keymap" OFF "fr_CH" "keymap" OFF "fr_CH-latin1" "keymap" OFF "gr" "keymap" OFF "gr-pc" "keymap" OFF "hu" "keymap" OFF "hu101" "keymap" OFF "il" "keymap" OFF "il-heb" "keymap" OFF "il-phonetic" "keymap" OFF "is-latin1" "keymap" OFF "is-latin1-us" "keymap" OFF "it" "keymap" OFF "it-ibm" "keymap" OFF "it2" "keymap" OFF "jp106" "keymap" OFF "kazakh" "keymap" OFF "keypad" "keymap" OFF "ky_alt_sh-UTF-8" "keymap" OFF "kyrgyz" "keymap" OFF "la-latin1" "keymap" OFF "lt" "keymap" OFF "lt.baltic" "keymap" OFF "lt.l4" "keymap" OFF "lv" "keymap" OFF "lv-tilde" "keymap" OFF "mac-be" "keymap" OFF "mac-de-latin1" "keymap" OFF "mac-de-latin1-nodeadkeys" "keymap" OFF "mac-de_CH" "keymap" OFF "mac-dk-latin1" "keymap" OFF "mac-dvorak" "keymap" OFF "mac-es" "keymap" OFF "mac-euro" "keymap" OFF "mac-euro2" "keymap" OFF "mac-fi-latin1" "keymap" OFF "mac-fr" "keymap" OFF "mac-fr_CH-latin1" "keymap" OFF "mac-it" "keymap" OFF "mac-pl" "keymap" OFF "mac-pt-latin1" "keymap" OFF "mac-se" "keymap" OFF "mac-template" "keymap" OFF "mac-uk" "keymap" OFF "mac-us" "keymap" OFF "mk" "keymap" OFF "mk-cp1251" "keymap" OFF "mk-utf" "keymap" OFF "mk0" "keymap" OFF "nl" "keymap" OFF "nl2" "keymap" OFF "no" "keymap" OFF "no-dvorak" "keymap" OFF "no-latin1" "keymap" OFF "pc110" "keymap" OFF "pl" "keymap" OFF "pl1" "keymap" OFF "pl2" "keymap" OFF "pl3" "keymap" OFF "pl4" "keymap" OFF "pt-latin1" "keymap" OFF "pt-latin9" "keymap" OFF "pt-olpc" "keymap" OFF "ro" "keymap" OFF "ro_std" "keymap" OFF "ro_win" "keymap" OFF "ru" "keymap" OFF "ru-cp1251" "keymap" OFF "ru-ms" "keymap" OFF "ru-yawerty" "keymap" OFF "ru1" "keymap" OFF "ru2" "keymap" OFF "ru3" "keymap" OFF "ru4" "keymap" OFF "ru_win" "keymap" OFF "ruwin_alt-CP1251" "keymap" OFF "ruwin_alt-KOI8-R" "keymap" OFF "ruwin_alt-UTF-8" "keymap" OFF "ruwin_alt_sh-UTF-8" "keymap" OFF "ruwin_cplk-CP1251" "keymap" OFF "ruwin_cplk-KOI8-R" "keymap" OFF "ruwin_cplk-UTF-8" "keymap" OFF "ruwin_ct_sh-CP1251" "keymap" OFF "ruwin_ct_sh-KOI8-R" "keymap" OFF "ruwin_ct_sh-UTF-8" "keymap" OFF "ruwin_ctrl-CP1251" "keymap" OFF "ruwin_ctrl-KOI8-R" "keymap" OFF "ruwin_ctrl-UTF-8" "keymap" OFF "se-fi-ir209" "keymap" OFF "se-fi-lat6" "keymap" OFF "se-ir209" "keymap" OFF "se-lat6" "keymap" OFF "sg" "keymap" OFF "sg-latin1" "keymap" OFF "sg-latin1-lk450" "keymap" OFF "sk-prog-qwerty" "keymap" OFF "sk-prog-qwertz" "keymap" OFF "sk-qwerty" "keymap" OFF "sk-qwertz" "keymap" OFF "slovene" "keymap" OFF "sr-cy" "keymap" OFF "sun-pl" "keymap" OFF "sun-pl-altgraph" "keymap" OFF "sundvorak" "keymap" OFF "sunkeymap" "keymap" OFF "sunt4-es" "keymap" OFF "sunt4-fi-latin1" "keymap" OFF "sunt4-no-latin1" "keymap" OFF "sunt5-cz-us" "keymap" OFF "sunt5-de-latin1" "keymap" OFF "sunt5-es" "keymap" OFF "sunt5-fi-latin1" "keymap" OFF "sunt5-fr-latin1" "keymap" OFF "sunt5-ru" "keymap" OFF "sunt5-uk" "keymap" OFF "sunt5-us-cz" "keymap" OFF "sunt6-uk" "keymap" OFF "sv-latin1" "keymap" OFF "tj_alt-UTF8" "keymap" OFF "tr_f-latin5" "keymap" OFF "tr_q-latin5" "keymap" OFF "tralt" "keymap" OFF "trf" "keymap" OFF "trf-fgGIod" "keymap" OFF "trq" "keymap" OFF "ttwin_alt-UTF-8" "keymap" OFF "ttwin_cplk-UTF-8" "keymap" OFF "ttwin_ct_sh-UTF-8" "keymap" OFF "ttwin_ctrl-UTF-8" "keymap" OFF "ua" "keymap" OFF "ua-cp1251" "keymap" OFF "ua-utf" "keymap" OFF "ua-utf-ws" "keymap" OFF "ua-ws" "keymap" OFF "uk" "keymap" OFF "unicode" "keymap" OFF "us" "keymap" ON "us-acentos" "keymap" OFF "wangbe" "keymap" OFF "wangbe2" "keymap" OFF "windowkeys" "keymap" OFF)

# DE/WM's
	BUDGIE="budgie-desktop budgie-extras baobab cheese eog epiphany evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-contacts gnome-control-center nome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-getting-started-docs gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-todo gnome-user-docs gnome-user-share gnome-video-effects grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager orca rygel sushi totem tracker tracker-miners vino xdg-user-dirs-gtk yelp gnome-boxes gnome-software simple-scan"
	CINNAMON="cinnamon"
	GNOME="baobab cheese eog epiphany evince file-roller gedit gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-contacts gnome-control-center nome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-getting-started-docs gnome-keyring gnome-logs gnome-maps gnome-menus gnome-music gnome-photos gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-todo gnome-user-docs gnome-user-share gnome-video-effects grilo-plugins gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager orca rygel sushi totem tracker tracker-miners vino xdg-user-dirs-gtk yelp gnome-boxes gnome-software simple-scan accerciser brasero dconf-editor devhelp evolution five-or-more four-in-a-row gnome-builder gnome-chess gnome-devel-docs gnome-klotski gnome-mahjongg gnome-mines gnome-nettool gnome-nibbles gnome-robots gnome-sound-recorder gnome-sudoku gnome-taquin gnome-tetravex gnome-tweaks gnome-weather hitori iagno lightsoff nautilus-sendto polari quadrapassel swell-foop sysprof tali gedit-code-assistance gnome-code-assistance gnome-multi-writer gnome-recipes gnome-usage"
	KDE="plasma-meta kde-applications-meta"
	LXDE="gpicview lxappearance lxappearance-obconf lxde-common lxde-icon-theme lxhotkey lxinput lxlauncher lxmusic lxpanel lxrandr lxsession lxtask lxterminal openbox pcmanfm"
	LXQT="lximage-qt lxqt-about lxqt-admin lxqt-config lxqt-globalkeys lxqt-notificationd lxqt-openssh-askpass lxqt-panel lxqt-policykit lxqt-powermanagement lxqt-qtplugin lxqt-runner lxqt-session lxqt-sudo lxqt-themes obconf-qt openbox pcmanfm-qt qterminal"
	MATE="caja marco mate-backgrounds mate-control-center mate-desktop mate-icon-theme mate-menus mate-notification-daemon mate-panel mate-polkit mate-session-manager mate-settings-daemon mate-themes mate-user-guide atril caja-image-converter caja-open-terminal caja-sendto caja-share caja-wallpaper caja-xattr-tags engrampa eom mate-applets mate-calc mate-icon-theme-faenza mate-media mate-netbook mate-power-manager mate-screensaver mate-sensors-applet mate-system-monitor mate-terminal mate-user-share mate-utils mozo pluma"
	XFCE="exo garcon gtk-xfce-engine thunar thunar-volman tumbler xfce4-appfinder xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xfwm4-themes mousepad orage thunar-archive-plugin thunar-media-tags-plugin xfburn xfce4-artwork xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-dict xfce4-diskperf-plugin xfce4-eyes-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-mpc-plugin xfce4-netload-plugin xfce4-notes-plugin xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-taskmanager xfce4-time-out-plugin xfce4-timer-plugin xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin xfce4-xkb-plugin parole ristretto xfce4-whiskermenu-plugin"
	I3WM="i3-gaps rofi"

	if [ "$INTERFACE" == "BUDGIE" ]; then
		UI="$BUDGIE"
	elif [ "$INTERFACE" == "CINNAMON" ]; then
		UI="$CINNAMON"
	elif [ "$INTERFACE" == "GNOME" ]; then
		UI="$GNOME"
	elif [ "$INTERFACE" == "KDE" ]; then
		UI="$KDE"
	elif [ "$INTERFACE" == "LXDE" ]; then
		UI="$LXDE"
	elif [ "$INTERFACE" == "LXQT" ]; then
		UI="$LXQT"
	elif [ "$INTERFACE" == "MATE" ]; then
		UI="$MATE"
	elif [ "$INTERFACE" == "XFCE" ]; then
		UI="$XFCE"
	elif [ "$INTERFACE" == "I3WM" ]; then
		UI="$I3WM"
	elif [ "$INTERFACE" == "NODEORWM" ]; then
		UI=""
	fi

# DM's
	gdm="gdm"
	lightdm="lightdm lightdm-gtk-greeter"
	lxdm="lxdm"
	sddm="sddm"

	if [ "$DISPLAYMANAGER" == "GDM" ]; then
		DM="$gdm"
	elif [ "$DISPLAYMANAGER" == "SDDM" ]; then
		DM="$sddm"
	elif [ "$DISPLAYMANAGER" == "LXDM" ]; then
		DM="$lxdm"
	elif [ "$DISPLAYMANAGER" == "LIGHTDM" ]; then
		DM="$lightdm"
	elif [ "$DISPLAYMANAGER" == "NODM" ]; then
		DM=""
	fi

# Nvidia (i)GPU
	if $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation" > /dev/null 2>&1); then
		echo "nVIDIA (i)GPU found, drivers will be installed"
		NVIDIA="nvidia nvidia-utils nvidia-settings"
	else
		NVIDIA=""
	fi

# AMD (i)GPU
	if $(lspci | grep -i "VGA compatible controller: Advanced Micro Devices" > /dev/null 2>&1); then
		echo "AMD (i)GPU found, drivers will be installed"
		AMD="xf86-video-amdgpu vulkan-radeon libva-mesa-driver"
	else
		AMD=""
	fi

# Packages
	BASE="bash bzip2 coreutils cryptsetup device-mapper dhcpcd diffutils e2fsprogs file filesystem findutils gawk gcc-libs gettext glibc grep gzip inetutils iproute2 iputils jfsutils less licenses linux logrotate lvm2 man-db man-pages mdadm nano netctl pacman pciutils perl procps-ng psmisc reiserfsprogs s-nail sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux vi which xfsprogs"
	BASE_DEVEL="autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed sudo systemd texinfo util-linux which"
	PACKAGES="$BASE $BASE_DEVEL $UI $DM $NVIDIA $AMD $CUSTOM_PACKAGES $OTHER_CUSTOM_PACKAGES mesa xorg-server os-prober networkmanager htop iftop iotop grub efibootmgr ntp hwloc"

# unmounting drives
	echo "-==unmounting drives==-"
	if $NVME; then
		umount ${TARGET_DRIVE}p1 /mnt/boot
	else
		umount ${TARGET_DRIVE}1 /mnt/boot
	fi
	if $NVME; then
		umount ${TARGET_DRIVE}p2 /mnt/
	else
		umount ${TARGET_DRIVE}2 /mnt/
	fi

# installing arch
	echo "-==Starting Arch Installation==-"
	timedatectl set-ntp true

	echo "-==checking if system is capeable of EFI==-"
	if ls /sys/firmware/efi/efivars > /dev/null 2>&1; then
		EFI=true
	else
		EFI=false
	fi

	echo "-==checking if $TARGET_DRIVE is an SSD==-"
	if [ "$(cat /sys/block/$(echo $TARGET_DRIVE | cut -d'/' -f3)/queue/rotational)" = "0" ]; then
		SSD=true
		echo "-==$TARGET_DRIVE is an SSD, trim will be enabled for cryptsetup==-"
	fi

	echo "-==Formatting drives/partitions==-"
	sgdisk -og ${TARGET_DRIVE}
	if $EFI; then
		sgdisk -n 1:0:+512M -c 1:"EFI" -t 1:ef00 ${TARGET_DRIVE}
	fi
	SYSTEM_PARTITION=$(if $EFI; then echo 2; else echo 1; fi)
	sgdisk -n $SYSTEM_PARTITION:0:0 -c $SYSTEM_PARTITION:"System" -t $SYSTEM_PARTITION:8300 ${TARGET_DRIVE}

	if $NVME; then
		if $EFI; then
			mkfs.fat -F32 ${TARGET_DRIVE}p1
		fi
		if $ENCRYPT_DRIVE; then
			cryptsetup -y -v luksFormat --type luks2 ${TARGET_DRIVE}p$SYSTEM_PARTITION
			cryptsetup open $(if $SSD; then echo "--allow-discards"; fi) ${TARGET_DRIVE}p$SYSTEM_PARTITION cryptroot
			mkfs.btrfs /dev/mapper/cryptroot
		else
			mkfs.btrfs ${TARGET_DRIVE}p$SYSTEM_PARTITION
		fi
	else
		if $EFI; then
			mkfs.fat -F32 ${TARGET_DRIVE}1
		fi
		if $ENCRYPT_DRIVE; then
			cryptsetup -y -v luksFormat --type luks2 ${TARGET_DRIVE}2
			cryptsetup open $(if $SSD; then echo "--allow-discards"; fi) ${TARGET_DRIVE}$SYSTEM_PARTITION cryptroot
			mkfs.btrfs /dev/mapper/cryptroot
		else
			mkfs.btrfs ${TARGET_DRIVE}$SYSTEM_PARTITION
		fi
	fi

	sgdisk -p ${TARGET_DRIVE}

	echo "-==Mouting formatted drives==-"
	if $ENCRYPT_DRIVE; then
		mount /dev/mapper/cryptroot /mnt
	else
		if $NVME; then
				mount ${TARGET_DRIVE}p$SYSTEM_PARTITION /mnt/
		else
			mount ${TARGET_DRIVE}$SYSTEM_PARTITION /mnt/
		fi
	fi
	if $EFI; then
		mkdir /mnt/boot/
		if $NVME; then
			mount ${TARGET_DRIVE}p1 /mnt/boot
		else
			mount ${TARGET_DRIVE}1 /mnt/boot
		fi
	fi

# Install packages
	echo "-==Installing base packages==-"
	if [[ "$INTERFACE" == KDE && "$DISPLAYMANAGER" == "$sddm" ]]; then
  	pacstrap /mnt ${PACKAGES} sddm-kcm
	else
		pacstrap /mnt ${PACKAGES}
	fi

# Encrypt drive
	if $ENCRYPT_DRIVE; then
		echo "-==configuring mkinitcpio.conf and grub config for encryption==-"
		sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)/" /mnt/etc/mkinitcpio.conf
		sed -ir "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"([^\s\s]*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 cryptdevice=UUID=device-UUID:cryptroot$(if $SSD; then echo ":allow-discards"; fi) root=\/dev\/mapper\/cryptroot\"/" /mnt/etc/default/grub
	fi

# Generate fstab
	echo "-==Generating FS Tab==-"
	genfstab -U /mnt >> /mnt/etc/fstab

# Configure timezone
	echo "-==Configuring Time Zone==-"
	arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
	arch-chroot /mnt hwclock --systohc

# Configure locale
	echo "-==Configuring Locale==-"
	echo "$LOCALE" >> /mnt/etc/locale.gen
	arch-chroot /mnt locale-gen
	echo "LANG=$(echo $LOCALE | cut -d' ' -f1)" >> /mnt/etc/locale.conf
	echo "KEYMAP=$KEYMAP" >> /mnt/etc/vconsole.conf

# Add user
	echo "-==Adding Normal User==-"
	arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $USERNAME
	arch-chroot /mnt echo $USERNAME:$PASSWORD | chpasswd

# Set hostname
	echo "-==Setting Hostname==-"
	echo "${HOSTNAME}" > /mnt/etc/hostname
	echo "127.0.0.1 localhost ${HOSTNAME}" >> /mnt/etc/hosts

# Install grub
	echo "-==Installing GRUB==-"
	arch-chroot /mnt mkinitcpio -p linux
	arch-chroot /mnt grub-install $(if $EFI; then echo "--target=x86_64-efi --efi-directory=/boot --bootloader-id=${BOOTLOADER_ID}"; else echo "--target=i386-pc"; fi) --recheck $(if !$EFI; then echo "$TARGET_DRIVE"; fi)
	echo "-==creating GRUB configuration==-"
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
	arch-chroot /mnt systemctl enable NetworkManager
	if [ "$DISPLAYMANAGER" != "nodm" ]; then
		arch-chroot /mnt systemctl enable $DISPLAYMANAGER
	fi
	arch-chroot /mnt systemctl enable ntpd

	echo "-==Arch is ready to be used"
