#!/bin/sh

# chrome-dl 0.1
# no input validation, error checking, failed download resumption, etc.

PLATFORMS='win linux mac'
CHANNEL='stable'
JSON_URL='https://omahaproxy.appspot.com/all.json'
JSON=all.json
CACHE_FILE='version.txt'

WGET='wget --no-verbose --random-wait -S --no-check-certificate'

VERSION_WIN=''
POSITION_WIN=''
RELDATE_WIN=''

VERSION_LINUX=''
POSITION_LINUX=''
RELDATE_LINUX=''

VERSION_MAC=''
POSITION_MAC=''
RELDATE_MAC=''

do_cleanup()
{
  rm $JSON
}

print_info()
{
  case "$1" in
    win)
      echo -n "Win: $VERSION_WIN ("
      echo -n "$POSITION_WIN) "
      echo $RELDATE_WIN
    ;;
    linux)
      echo -n "Lin: $VERSION_LINUX ("
      echo -n "$POSITION_LINUX) "
      echo $RELDATE_LINUX
    ;;
    mac)
      echo -n "Mac: $VERSION_MAC ("
      echo -n "$POSITION_MAC) "
      echo $RELDATE_MAC
    ;;
    esac
}

get_json()
{
  #TODO: error checking
  wget --no-check-certificate $JSON_URL -O $JSON 2>/dev/null
  if [ $? != 0 ]
  then 
    echo get_json fail
    exit 1 
  fi
}

get_json_data()
{
  case "$1" in
    win)
      VERSION_WIN=`jshon -F $JSON -e 0 \
                   -e versions -e 4 -e version -u`
      POSITION_WIN=`jshon -F $JSON -e 0 \
                    -e versions -e 4 -e branch_base_position -u`
      RELDATE_WIN=`jshon -F $JSON -e 0 \
                   -e versions -e 4 -e current_reldate -u`
    ;;
    linux)
      VERSION_LINUX=`jshon -F $JSON -e 1 \
                     -e versions -e 2 -e version -u`
      POSITION_LINUX=`jshon -F $JSON -e 1 \
                      -e versions -e 2 -e branch_base_position -u`
      RELDATE_LINUX=`jshon -F $JSON -e 1 \
                     -e versions -e 2 -e current_reldate -u`
    ;;
    mac)
      VERSION_MAC=`jshon -F $JSON -e 4 \
                   -e versions -e 2 -e version -u`
      POSITION_MAC=`jshon -F $JSON -e 4 \
                    -e versions -e 2 -e branch_base_position -u`
      RELDATE_MAC=`jshon -F $JSON -e 4 \
                   -e versions -e 2 -e current_reldate -u`
    ;;
  esac
}

#TODO: verify JSON for expected values in expected positions
verify_json()
{
  case "$1" in
    win)
      echo "win"
    ;;
    mac)
      echo "mac"
    ;;
    linux)
      echo "linux"
    ;;
    *)
     echo "lolwut"
    ;;
  esac
}

download_for_os()
{
  case "$1" in
    win)
      # X86
      $WGET https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B723B8F65-E944-7F01-6F35-18A40050626C%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dstable-arch_x86-statsdef_0%26brand%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle.zip

      # X64
      $WGET https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B723B8F65-E944-7F01-6F35-18A40050626C%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip

      # Chrome ADM/ADMX templates
      $WGET https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip
      # Chrome dev policy template
      $WGET https://dl.google.com/chrome/policy/dev_policy_templates.zip
      # Chrome beta policy template
      $WGET https://dl.google.com/chrome/policy/beta_policy_templates.zip
      # Google Updater ADM template update
      $WGET https://dl.google.com/update2/enterprise/GoogleUpdate.adm
      # Google Updater ADMX template update
      $WGET https://dl.google.com/dl/update2/enterprise/googleupdateadmx.zip
    ;;
    linux)
      # 64 bit .deb (For Debian/Ubuntu)
      $WGET https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      # 64 bit .rpm (For Fedora/openSUSE)
      $WGET https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    ;;
    mac)
      $WGET https://dl.google.com/dl/chrome/mac/universal/stable/gcem/GoogleChrome.pkg
      $WGET https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.dmg
    ;;
    *)
      echo 'lolwut'
    ;;
  esac
}

download_shit()
{
  case "$1" in
    win)
      DLDIR=Win_$VERSION_WIN
      mkdir $DLDIR && cd $DLDIR && download_for_os win && cd ..
    ;;
    linux)
      DLDIR=Linux_$VERSION_LINUX
      mkdir $DLDIR && cd $DLDIR && download_for_os linux && cd ..
    ;;
    mac)
      DLDIR=Mac_$VERSION_MAC
      mkdir $DLDIR && cd $DLDIR && download_for_os mac && cd ..
    ;;
  esac
}

update_cache_file()
{
  cat << EOF > $CACHE_FILE
CACHE_DATE='`date -u`'

CACHE_VERSION_WIN='$VERSION_WIN' 
CACHE_POSITION_WIN='$POSITION_WIN'
CACHE_RELDATE_WIN='$RELDATE_WIN'

CACHE_VERSION_LINUX='$VERSION_LINUX'
CACHE_POSITION_LINUX='$POSITION_LINUX'
CACHE_RELDATE_LINUX='$RELDATE_LINUX'

CACHE_VERSION_MAC='$VERSION_MAC'
CACHE_POSITION_MAC='$POSITION_MAC'
CACHE_RELDATE_MAC='$RELDATE_MAC'
EOF
}


check_version_and_download()
{
  if [ ! -f $CACHE_FILE ]
  then
    echo "No cache file ${CACHE_FILE}: downloading all"
    for p in $PLATFORMS
    do
      print_info $p
      download_shit $p
    done
    return
   fi

  . $PWD/$CACHE_FILE

  if [ $CACHE_VERSION_WIN = $VERSION_WIN ]
  then
    :
  else
    print_info win
    download_shit win 
  fi

  if [ $CACHE_VERSION_LINUX = $VERSION_LINUX ]
  then
    : 
  else
    print_info linux
    download_shit linux
  fi

  if [ $CACHE_VERSION_MAC = $VERSION_MAC ]
  then
    : 
  else
    print_info mac
    download_shit mac
  fi
}

#
# script main
#
date -u
echo 'chrome-dl 0.1 2023/02/09'

get_json

for p in $PLATFORMS
do
  get_json_data $p
done

check_version_and_download
update_cache_file
#do_cleanup

