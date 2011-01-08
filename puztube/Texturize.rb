LIST_OPEN_TAGS = { '#' => '<ol>',
		       '-' => '<ul>' };
LIST_CLOSE_TAGS = { '#' => '</ol>',
			'-' => '</ul>' };

DEFAULT_OPTIONS = { :p => 1,
			 :pre => 1,
			 :list => 1,
			 :tab => 1,
			 :comma => 1,
			 :b => 1,
			 :i => 1,
			 :emdash => 1,
			 :http => 1,
			 :quote => 1,
		       };

  def texturize(text) 
    #warn "texturize: $text";

    # standardize newlines and collapse
    text.gsub!(/\r\n/,/\n/);
    text.gsub!(/^\n+/,//);
    text.sub!(/\n+$/,//);
    text.gsub!(/\n\n+/,/\n\n/);
    
    my @tags;
    
    # protect tag contents
    $text =~ s/<([^>]+)>/push(@tags,$1); "<$#tags>"/ge; 
    
    lines = text.split(/\n/);

    #warn "texturize";
    #for (my $i = 0; $i<@lines; $i++) {
    #	warn sprintf("%4d: %s\n", $i, $lines[$i]);
    #}

    # protected <pre> blocks
    my @pre;
    lines.each do |i|
	# lines starting with > -> <div class="quotation">
	if lines[i].gsub!(/^>/,'')
	  (i+1...lines.length).each do |j|
            break if !lines[j].gsub(/^>/,'')
	  end
	    
	    content = join("\n", splice(lines, $i, $end - $i));
	    content = texturize(content, { wiki => 0, http => 0 } );
	    content = "<div class=\"quotation\">\n#{content}\n</div>";
	    splice(@lines, $i, 0, $content);
	# lines starting with space or tab -> <pre>
	elsif lines[i].gsub(/^[ \t]/,'')
          (i+1...lines.length).each do |j|
	    break if !lines[j].gsub(/^[ \t]/,'');
          end
		
	  content = join("\n", splice(@lines, $i, $end - $i, 
					    "<pre><pre" . @pre . "></pre>"));
	  push(@pre, $content);
        # tables
	elsif lines[i] =~ /^TAB/
          (i+1...lines.length).each do |j|
            break if lines[j] =~ /^ENDTAB/
          end
	    
	    my $content = join("\n", splice(@lines, $i + 1, $end - $i - 1)) . "\n";
	    $content = tsv_html(\%options, $content);
	    splice(@lines, $i, 2, $content);
	}

	# tables
	elsif ($options{comma} && $lines[$i] =~ m/^COMMA/) {
	    my $end;
	    for ($end = $i+1; $end<@lines; $end++) {
		last if ($lines[$end] =~ m/^ENDCOMMA/);
	    }
	    
	    my $content = join("\n", splice(@lines, $i + 1, $end - $i - 1)) . "\n";
	    #warn "comma: $content";
	    $content = csv_html(\%options, $content);
	    splice(@lines, $i, 2, $content);
	}
    }

    # lists
    if ($options{list}) {
	my @old;
	foreach (my $i = 0; $i<@lines; $i++) {
	    if ($lines[$i] =~ s/^([-#]*)//) {
		#warn "\n$1$lines[$i]\n" if $1;
		$lines[$i] = "<li> $lines[$i] </li>" if $1;
		@new = split(//, $1);
		#warn "old " . join('',@old)  . " new " . join('',@new) .  "\n";
		
		my $changes;
		my $diff; # first difference
		for ($diff = 0; $diff < @old; $diff++) {
		    last if ($new[$diff] ne $old[$diff]);
		}
		#warn "diff $diff\n";
		
		for (my $j = $diff; $j < @old; $j++) {
		    $changes = (' ' x $j) . $LIST_CLOSE_TAGS{$old[$j]} . "\n" . $changes;
		}
		for (my $j = $diff; $j < @new; $j++) {
		    $changes .= (' ' x $j) . $LIST_OPEN_TAGS{$new[$j]} . "\n";
		}
		$lines[$i] = $changes . (' ' x @new) . $lines[$i];
		@old = @new;
	    }
	}
	for (my $j = 0; $j < @old; $j++) {
	    push(@lines, (' ' x $j) . $LIST_CLOSE_TAGS{$old[$j]});
	}

    }	

    # paragraphs
    if ($options{p}) {
	foreach (my $i = 0; $i<@lines; $i++) {
	    if ($lines[$i] eq "") {
		$lines[$i] = "</p>\n\n<p>";
	    }
	}

	unshift(@lines, "<p>\n");
	push(@lines,"</p>\n");
    }

    $text = join("\n", @lines);
	
    # bold
    if ($options{b}) { # use \b here
	$text =~ s{(?<!\w)\*(\S[^*]*\S|\S)\*(?!\w)}{<b>$1</b>}g;
    }
    
    # italic
    if ($options{i}) {
	$text =~ s{(?<!\w)_(\S[^_]*\S|\S)_(?!\w)}{<i>$1</i>}g;
    }
	
    # emdash
    if ($options{emdash}) {
	$text =~ s/--/&#8212;/g;
    }

    # restore pre contents
    $text =~ s/<pre(\d+)>/$pre[$1]/g;

    # http links
    if ($options{http}) {
	$text =~ s{\b((https?|ftp|irc)://\S+)}{push(@tags,"a href=\"$1\">$1</a"); "<$#tags>"}gie;
    }

    # wiki links
    if ($options{wiki}) {
	# WikiWords
	$text =~ s{\b([A-Z]\w*[a-z]\w*[A-Z]\w*)\b}{push(@tags,"a class=\"wikilink\" href=\"$options{wikiprefix}$1\">$1</a"); "<$#tags>"}ge;
    }
    

    # restore tag contents
    $text =~ s/<(\d+)>/<$tags[$1]>/g;
    
    #warn "texturized: $text";
    
    return $text;
    end

sub csv_array {
    my ($csv) = @_;

    # cases where the cell is """text"""
    $csv =~ s/(^|,|\n)"""/$1"&quot;/g;
    $csv =~ s/"""($|,|\n)/&quot;"$1/g;
    
    $csv =~ s/""/&quot;/g;
    
    my @rows;
    my $i;

    while ($csv) {
	if ($csv =~ s/^[ \t]*"([^"]*)"[ \t]*(,|\n|$)//) {
	    #warn "1: $1 ($2) " . ($2 eq "\n");
	    my $cell = $1;
	    my $terminator = $2;
	    $cell =~ s/&quot;/"/g;
	    push(@{$rows[$i]}, $cell);
	    $i++ if ($terminator eq "\n");
	} elsif ($csv =~ s/^(.*?)(,|\n|$)//) {
	    #warn "2: $1";
	    push(@{$rows[$i]}, $1);
	    $i++ if ($2 eq "\n");
	} else {
	    #warn "3: $1";
	    push(@{$rows[$i]}, $1);
	    $csv = '';
	}
    }
    
    return @rows;
}    

sub tsv_array {
    my ($tsv) = @_;

    return map { [ split("\t", $_) ] } split("\n", $tsv);
}

sub array_table {
    my (@rows) = @_;
    
    return "<table border=\"1\">\n<tr>\n" . 
	join("</tr>\n<tr>\n",
	     map { "  <td>" . 
		       join("</td>\n  <td>", @{$_}) .
			   "</td>\n" } @rows) .
			       "</tr>\n</table>\n";
}

sub cell_csv {
    my ($cell) = @_;
    
    if ($cell =~ m/[,"\n]/) {
	$cell =~ s/"/""/g;
	$cell = '"' . $cell . '"';
    }
    return $cell;
}
    
sub array_csv {
    my (@rows) = @_;
    
    return join("\n",
		map { join(",", map { cell_csv($_) } @{$_}) } @rows) .
		    "\n";
}

sub array_tsv {
    my (@rows) = @_;

    return join("\n",
		map { join("\t", @{$_}) } @rows) .
		    "\n";
}

sub array_html {
    my ($options, @array) = @_;

    my $html = array_table(@array);

    if (my $csv_link = $options->{csvlink}) {
	my $encoded = array_csv(@array);
	$encoded =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
	$html .= qq{<a href="$csv_link?csv=$encoded">CSV</a> };
    }

    if (my $tsv_link = $options->{tsvlink}) {
	my $encoded = array_tsv(@array);
	$encoded =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
	$html .= qq{<a href="$tsv_link?tsv=$encoded">TSV</a> };
    }

    if (my $pzt_link = $options->{pztlink}) {
    	my $encoded = array_csv(@array);
	$encoded =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
	$html .= qq{<a href="#" onclick="window.open('$pzt_link?csv=$encoded','_new','directories=no,scrollbars=yes,resizable=yes,toolbar=no,location=no,height=500,width=400'); return false;">Puzzletron</a>};
    }
    return $html;
}

sub csv_html {
    my ($options, $csv) = @_;
    
    return array_html($options, csv_array($csv));
}

sub tsv_html {
    my ($options, $tsv) = @_;
    
    return array_html($options, tsv_array($tsv));
}




1;
