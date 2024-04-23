#!/usr/bin/env sh

cat <<EOT > $(git rev-parse --git-dir)/mediawikireleasenotes.rb
#!/usr/bin/env ruby

def fail info=nil
	puts "I don't know what to doooo!"
	puts info if info
	exit(-1)
end

parent, left, right = *ARGV
parent_ary, left_ary, right_ary = File.readlines(parent), File.readlines(left), File.readlines(right)


# Loads chunks
sleft = left_ary.slice_before{|e| e.start_with? '=='}.to_a
sright = right_ary.slice_before{|e| e.start_with? '=='}.to_a
sparent = parent_ary.slice_before{|e| e.start_with? '=='}.to_a

if sparent.length != sleft.length || sparent.length != sright.length
	fail "Incompatible number of sections (#{sparent.length} vs #{sleft.length} vs #{sright.length})."
end

# Strip trailing newlines
sleft.each{|a| a.pop while a.last.strip.empty? }
sright.each{|a| a.pop while a.last.strip.empty? }
sparent.each{|a| a.pop while a.last.strip.empty? }

# Group together the lines into "list items", "paragraphs" and "headers":
# * If a line begins with '==', it is a "header" and is kept separately
# * If a line begins with '* ', it is the start of a "list item"
#   and all following lines that begin with '  ' are merged with it
# * Otherwise, the line is the state of a "paragraph"
#   and all following lines until an empty line are merged with it
[sleft, sright, sparent].each do |sections|
	sections.map! do |lines|
		items = []
		state = nil

		lines.each do |line|
			case state
			when nil
				items << line
			when :listitem
				if line =~ /^  /
					items.last << line
				else
					items << line
				end
			when :paragraph
				items.last << line
			end

			if state == nil
				if line =~ /^\* /
					state = :listitem
				elsif line !~ /^==/ && line != "\n"
					state = :paragraph
				end
			elsif state == :paragraph && line == "\n"
				state = nil
			elsif state == :listitem && line !~ /^  / && line !~ /^* /
				state = nil
			end
		end

		items
	end
end

# Determine what was added in the right version
sadded = []
sright.each_index do |i|
	added = sright[i] - sparent[i];
	removed = sparent[i] - sright[i];
	unless removed.empty?
		fail "Non-trivial change, bailing out."
	end
	sadded << added
end

# And append it to the left version
sleft.each_index do |i|
	unless sadded[i].empty?
		# Keep the '…' markers at the end
		found_marker = sleft[i].delete "* …\n"
		sleft[i] += sadded[i]
		sleft[i].push "* …\n" if found_marker
	end
end

# Write back to file
File.binwrite( left, sleft.map{|lines| lines.join('') }.join("\n") )
exit 0
EOT

git config merge.mediawikireleasenotes.name "MediaWiki release notes merge driver"
git config merge.mediawikireleasenotes.driver 'ruby $(git rev-parse --git-dir)/mediawikireleasenotes.rb %O %A %B'

echo /RELEASE-NOTES* merge=mediawikireleasenotes >> $(git rev-parse --git-dir)/info/attributes
