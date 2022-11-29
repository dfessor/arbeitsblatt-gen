#!/bin/bash

# VARIABLES
mainFile=""
group=""
answerOpt=""
findLine="usepackage.*{arbeitsblatt}"
phase=""
suffix=""

# FUNCTIONS
fileChecker(){
	if [ -z $1 ]
	then
		echo "No File given. Looking for .tex file"
		mainFile=$(ls *.tex)
		echo "$mainFile found."
	else
		mainFile="$1"
	fi
}
findOption () {
	string=$1
	local output=$(grep "$findLine" "$mainFile" | grep -o "$string")
	echo "$output"
}
findGroup(){
	group=$(findOption "A")
	if [ -z "$group" ]
	then
		echo "We're looking if the group is B"
		group=$(findOption "B")
	fi
}
findAnswer(){
	answerOpt=$(findOption "noanswers")
	if [ -z "$answerOpt" ]
	then
		answerOpt=$(findOption "answers")
	fi
}
optionSwitcher() {
	local oldOption="$1"
	case "$oldOption" in
		"A") echo "B";;
		"B") echo "A";;
		"answers") echo "noanswers";;
		"noanswers") echo "answers";;
	esac
}
phaseFinder(){
	case "$1" in
		"Aanswers") 
			phase=0 
			suffix="-A-LSG"
			;;
		"Banswers") 
			phase=1 
			suffix="-B-LSG"
			;;
		"Bnoanswers") 
			phase=2
			suffix="-B"
			;;
		"Anoanswers") 
			phase=3
			suffix="-A"
			;;
		*) echo "PhaseError: Couldn't find Phase. ("$1")" 
	esac
	outputFile="${mainFile/.tex/"$suffix".tex}"
}
createPdf(){
	pdflatex $outputFile
	pdflatex $outputFile
	rm $outputFile ${outputFile/tex/aux} ${outputFile/tex/log}
}

fileChecker $1
findGroup # sets $groupAlt
groupAlt=$(optionSwitcher "$group")
findAnswer # sets $answerOptAlt
answerOptAlt=$(optionSwitcher "$answerOpt")
phaseFinder "$group$answerOpt" # sets $suffix
echo "File: $mainFile, Group: $group, Answer: $answerOpt"

# PHASE 1
echo "Phase 1"
cp "$mainFile" "$outputFile"
createPdf
# PHASE 2
echo "Phase 2"
phaseFinder "$groupAlt$answerOpt" # sets $suffix
sed -e '/usepackage/s/"$group"/"$groupAlt"/' "$mainFile" > "$outputFile"
createPdf
# PHASE 3
echo "Phase 3"
phaseFinder "$group$answerOptAlt" # sets $suffix
sed -e '/usepackage/s/"$answerOpt"/"$answerOptAlt"/' "$mainFile" > "$outputFile"
createPdf
# PHASE 4
echo "Phase 4"
phaseFinder "$groupAlt$answerOptAlt" # sets $suffix
sed -e '/usepackage/s/"$group"/"$groupAlt"/' -e '/usepackage/s/"$answerOpt"/"$answerOptAlt"/'  "$mainFile" > "$outputFile"
createPdf
