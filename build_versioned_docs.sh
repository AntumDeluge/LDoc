#!/usr/bin/env bash

d_root="$(dirname $(readlink -f $0))"

cd "${d_root}"

main_branch="$(git branch --show-current)"

mkdir "${d_root}/doc_builds"
for t in $(git tag | grep "^doc-v"); do
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
	mv "${d_root}/out" "${d_root}/doc_builds/$(echo ${t} | sed -e 's/^doc-v//')"
done

cd "${d_root}"
git checkout ${main_branch}
echo -e "\nDone!"
