#!/usr/bin/env bash

d_root="$(dirname $(readlink -f $0))"

cd "${d_root}"

main_branch="$(git branch --show-current)"

html_out="<html>\n<head></head>\n\n<body>\n\n<ul>\n"

mkdir -p "${d_root}/doc_builds"
for t in $(git tag -l --sort=-v:refname | grep "^doc-v"); do
	echo -e "\nbuilding ${t} ..."
	git checkout ${t}
	make doc-site
	ret=$?
	if test ${ret} -ne 0; then
		echo -e "\ndoc-site target not available, using traditional build ..."
		cd "${d_root}/doc" && lua "${d_root}/ldoc.lua" .
		ret=$?
		if test ${ret} -ne 0; then
			echo "an error occurred building ${t}"
			cd "${d_root}"
			git checkout ${main_branch}
			exit ${ret}
		fi
	fi
	vinfo="$(echo ${t} | sed -e 's/^doc-v//')"
	mv "${d_root}/out" "${d_root}/doc_builds/${vinfo}"
	if test -z ${latest+x}; then
		latest="${vinfo}"
		cp -r "${d_root}/doc_builds/${vinfo}" "${d_root}/doc_builds/latest"
		html_out="${html_out}  <li><a href=\"latest/\">latest</a></li>\n"
	fi
	html_out="${html_out}  <li><a href=\"${vinfo}/\">${vinfo}</a></li>\n"
done

html_out="${html_out}</ul>\n\n</body></html>"

cd "${d_root}"
git checkout ${main_branch}

echo -e "${html_out}" > "${d_root}/doc_builds/index.html"

echo -e "\nDone!"
