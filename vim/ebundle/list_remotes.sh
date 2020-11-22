./list_all.sh | while read l; do cd "$l"; echo "$l $(git remote -v | head -n1 | awk '{print $2}')"; cd ../../; done | sed 's@/@ @' | awk '{ section=$1 } oldsection!=section{ print "# " section; oldsection=section }  {print "Vundle \x27"$3"\x27"}'

