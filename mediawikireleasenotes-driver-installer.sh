git config merge.mediawikireleasenotes.name "MediaWiki release notes merge driver"
cat <<EOT > $(git rev-parse --git-dir)/mediawikireleasenotes.rb
#!/usr/bin/env ruby

parent, left, right = *ARGV

parent_ary, left_ary, right_ary = File.readlines(parent), File.readlines(left), File.readlines(right)

added_left, removed_left = left_ary-parent_ary, parent_ary-left_ary
added_right, removed_right = right_ary-parent_ary, parent_ary-right_ary

# it's okay if matches overlap, as recursive will handle it as well
matching_start = left_ary.zip(right_ary).take_while{|a,b| a == b }.length
matching_end = left_ary.reverse.zip(right_ary.reverse).take_while{|a,b| a == b }.length


# use union if we have consecutive additions only in both files.
# otherwise fall back to recursive.

if(
	removed_left.empty? && removed_right.empty? &&
	matching_start + added_left.length + matching_end == left_ary.length &&
	matching_start + added_right.length + matching_end == right_ary.length
)
	# all is well
	ok = system *%W[git merge-file --union #{left} #{parent} #{right}]
	exit(ok ? 0 : -1)
else
	# stuff was removed, fall back to regular merge
	ok = system *%W[git merge-file #{left} #{parent} #{right}]
	exit(ok ? 0 : -1)
end

EOT

git config merge.mediawikireleasenotes.driver 'ruby $(git rev-parse --git-dir)/mediawikireleasenotes.rb %O %A %B'


echo /RELEASE-NOTES* merge=mediawikireleasenotes >> .gitattributes
