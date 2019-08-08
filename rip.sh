#!/bin/bash

URL_ARCHIVE="https://secure2.linuxjournal.com/ljarchive/LJ/tocindex.html"
lynx -dump -listonly -nonumbers -hiddenlinks=ignore $URL_ARCHIVE > url_of_issues.txt
echo "A file called : 'url_of_issues.txt' has been created !"
echo ""

#Suppress the two first lines : no interest
tail -n +3 url_of_issues.txt > tmp.txt
mv tmp.txt url_of_issues.txt

#Suppress the two last lines : no interest
ghead -n -1 url_of_issues.txt > tmp.txt
mv tmp.txt url_of_issues.txt

#Suppress numerous line until we have only from issue 1 to 131
#We have PDF in better quality for issues >=132.
tail -n +171 url_of_issues.txt > tmp.txt
mv tmp.txt url_of_issues.txt




# 3 : For each issue downloading URL of all article available 
# ------------------------------------------------------------
#url will be like : https://secure2.linuxjournal.com/ljarchive/LJ/002/toc002.html

#Creating a folder for resulting PDF
mkdir "Linux Journal"
mkdir "Logbooks"
echo ""

#Downloading each article of an issue and creating one final PDF.
COUNT_A=1
while read LINE_A; do
  echo "We are in this folder : $LINE_A"
  TMP_A="${LINE_A#https://secure2.linuxjournal.com/ljarchive/LJ/*}"
  INDEX="${TMP_A%/*}"
  echo ""
  echo "--------------------------------------------------"
  echo " We are downloading issue $INDEX of Linux Journal…"
  echo ""
  weasyprint $LINE_A 0-$INDEX.pdf
  lynx -dump -listonly -nonumbers "$LINE_A" >> url_article_$INDEX.txt
  
  #Suppress the first line : no interest
  tail -n +2 url_article_$INDEX.txt > tmp.txt
  mv tmp.txt url_article_$INDEX.txt

  #Suppress the two last lines : no interest
  ghead -n -2 url_article_$INDEX.txt > tmp.txt
  mv tmp.txt url_article_$INDEX.txt
  
  #Here we do most of the job for every article in each issue:
  COUNT_B=1
  while read LINE_B; do
    # Downloading every article in PDF
    echo " We are downloading this article : $LINE_B from issue $INDEX"
    echo "$COUNT_B"
    if [ "$COUNT_B" -lt 10 ] ; then
      weasyprint "$LINE_B" "$COUNT_B-$INDEX.pdf"
    else
      if [ "$COUNT_B" -lt 20 ] ; then
        weasyprint "$LINE_B" "A$COUNT_B-$INDEX.pdf"
      else
        weasyprint "$LINE_B" "B$COUNT_B-$INDEX.pdf"
      fi
    fi
    
    COUNT_B=`expr $COUNT_B + 1`
  done < "url_article_$INDEX.txt"
  
  # Concatenate PDF into one but with respect to the alphabetical order of your OS.
  convert *.pdf "Linux Journal - $INDEX.pdf"
    
  # Cleaning temporary PDFs
  mv "Linux Journal - $INDEX.pdf" "Linux Journal/Linux Journal - $INDEX.pdf"
  rm *.pdf
  
  # End of the work for this issue : PDF has been moved and rename, now move the log and increment.
  mv "url_article_$INDEX.txt" "Logbooks/url_article_$INDEX.txt"
  COUNT_A=`expr $COUNT_A + 1`
done < "url_of_issues.txt"

echo "Et voilà!"