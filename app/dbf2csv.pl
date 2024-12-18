#!/usr/bin/perl

# DBF2CSV.PL -- a program to convert .DBF files to .CSV or .json format
# (Written in Perl 4.036, and compatible with Perl 5.)
#
# This program is uncopyrighted, so do with it whatever you wish.
# By Dave Burton, Burton Systems Software, POB 4157, Cary, NC 27519-4157.
# email: http://www.burtonsys.com/email/

# The latest version of DBF2CSV can always be found on the Burton
# Systems Software web site, in the "downloads" area:
# http://www.burtonsys.com/


#  =>keyflag<=-- "%v, %d"
$ver_ordinal_and_date = "41, 03-Dec-16";
# the TLIB Version Control version number and last-modified date


######## HISTORY ########
#
# Dbf2csv v1, 12/22/2000 - Convert .DBF files to .CSV format.
# The "-p" option selects interactive mode, for use with Perl4w.exe,
# to make a Windows program.
#
# Dbf2csv v2, 4/14/2003 - handles some ideosyncratic .dbf files with
# non-standard headers, which confused v1.
#
# Dbf2csv v3 (unreleased) - added support for fields > 255 characters
# thanks to Jeff Price, and for big-endian machines (for John McVeagh).
#
# v1 was modified (commented, corrected & enhanced to handle accented
# characters) by Jacky Bruno <jacky.bruno[at]free.fr> coll�ge de Villeneuve
# sur Yonne 89500, in april 2003.  His version was included in some of
# the dbf2csv.zip distributions as dbf2csv_accentued_characters.pl.
#
# Dbf2csv v4, 6/27/2003 - the result of merging most of Jacky's changes
# into the standard version of DBF2CSV.PL, plus a few more improvements.
# Also, changes '~' characters to blanks.
# [Shameless advertisement: of course I used the TLIB Version Control
# "migrate" command to do the merge and create v4.  See our web site,
# http://www.burtonsys.com/   -DAB]
#
# Dbf2csv v5, 1/24/2004 - adds the ability to properly handle FoxPro's
# 'I' fields, which are 4-byte little-endian binary integers (signed,
# I hope!).  Also, tries to tell you what program created the database,
# based on the version number.  Also, no longer changes '~'s to blanks.
#
# Dbf2csv v6, 5/7/2004 - by David Mar�n <dmarin-NO-SPAM@dyr.es>
# Handle almost all PC850 accented characters, not just French ones
#
# Dbf2csv v7, 7/19/2005 - 'F' fields now fully supported, and '+'
# fields now might work (untested, supported with a warning).  -DAB
#
# Dbf2csv v7.1-beta 10/9/2010 - Unsupported fields converted to hex. -DAB
#
# Dbf2csv v8, 2/20/2011 - 'B' fields (FoxPro 8-byte double-precsion)
# now work and negative values in 'I" fields now work correctly on
# small-endian machines (but still not on big-endian machines, sorry!).
# Also, added the "-j" option, to output a .json file instead of a .csv
# file (EXPERIMENTAL / lightly tested).  -DAB
#
# Dbf2csv v9, 5/22/2012 - 'T' fields (FoxPro 8-byte date+time) are now
# supported. -DAB
#
# Dbf2csv v10, 11/15/2012 -  Fixed detection of (unsupported) dBase 7
# files. -DAB
#
# Dbf2csv v11, 12/3/2016 -  Enabled escape-coding of special characters.
# -DAB
#
#########################

$version = "v11";


# This program is uncopyrighted, so it can be modified by anyone who
# wants to.  But, out of courtesy, please add your own name and what
# you did to the history, and do not remove the previous history.
# -DAB


# Here are some descriptions of the .dbf file format:
#   http://www.clicketyclick.dk/databases/xbase/format/
#   http://www.clicketyclick.dk/databases/xbase/format/data_types.html
#   http://web.archive.org/web/20080501103856/http://www.klaban.torun.pl/prog/pg2xbase/contrib/dbf-format.html
#   http://support.microsoft.com/kb/98743 or http://www.webcitation.org/67szzmtLQ (was http://support.microsoft.com/support/kb/articles/q98/7/43.asp)
#   http://web.archive.org/web/20060821235500/http://community.borland.com/article/0,1410,15838,00.html
#   http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm or http://www.webcitation.org/67t06OStF


# Jacky Bruno's additional comments... (but I updated the line numbers -DAB)
# The script structure is this one:
# lines 1509 to the end : main program :
#   - it reads command line: if no parameters, then it shows help
#   - treat flags if there are some (d, p)
#   - reads the first file name given and give it to the do_a_file function
#   - do the same with other command line given files
# lines 1333 to 1364 : do_a_file function (the name is clear) :
#   - verify the validity of the file (ending with .dbf)
#   - buids the .csv file name from the .dbf file name given
#   - calls the cvt1file function by giving her the 2 file names
#   - get the records's number and shows informations:
#      input file   output file    treated records number
# lines 610 to 1326 : cvt1file function :
#   - as his name tells, do the conversion job of input file
#   - write to screen informations of file beginning and field names
#   - save output file :
#       first field name, then each record


# In the output file, fields will be separated by $separe
#  $separe=";";
$separe=",";

$| = 1;   # predefined variable. If <> 0 then each print to the console
          # will immediatly be displayed, instead of buffered.

$debugmode = 0;  # set to 1 via '-d' for debug prints
$prompt = 0;  # set to 1 via '-p' for special interactive mode, for use with perl4w.exe
$jsonmode = 0;  # set to 1 via '-j' to output a JSON file instead of CSV
$escape_codes = -1;  # set to 1 via '-e' to translate CR, LF, etc. to "\r", "\n", etc. respectively
                     # or set to 2 via '-e2' to translate " to "" (not for json!)
                     # default is '-e0' (dumb/simple mode) for CSV, or '-e1' for json



$progversion_shown = 0;

# display program name and version (but only once!)
sub show_progversion {
   if (!$progversion_shown) {
      print "DBF2CSV $version -- Convert .DBF file to .CSV (comma-separated) format\n";
      $progversion_shown = 1;
   }
}


# display dbf2csv.pl version number (you might want to comment this out)
&show_progversion;

# Which version of Perl are they using?
$perlver = "3 or earlier";
if ($] =~ /\$\$Revision\:\s*([0-9.]+)\s/) {
   $perlver = $1;  # probably 4.something
} elsif ($] =~ /([0-9][0-9.]*)/) {
   $perlver = $1;  # probably 5.something or 6.something
}
print "You are using Perl version $perlver\n";

# is this a big-endian machine?
$big_endian = 0;
$tst = pack("S",513);
$tst_big_endian = unpack("n",$tst);
$tst_little_endian = unpack("v",$tst);
if ((513==$tst_big_endian) && (258==$tst_little_endian)) {
   # this is a big endian machine
   $big_endian = 1
}

# Does this version of Perl support IEEE-754 8-byte double-precision (Foxpro 'B')?
$perl_supports_IEEE754_doubles = 0;
$tstIEEE = "\x00\x00\x00\x00\x80\x05\xD1\x40";
$tst2 = unpack("d",$tstIEEE);
$tst3 = sprintf("%10.4f", $tst2);
if ($tst3 eq '17430.0000') {
   $perl_supports_IEEE754_doubles = 1;
}
$warned_about_B_field = 0;  # set to 1 when we issue a warning about inability to handle Foxpro 'B' fields (so we won't repeat the warning)

# Perl pack/unpack format representing the structure of the first
# 32 bytes in a .DBF file:
$DBF_header_fmt = "C" .   # version number at offset
                  "CCC" . # YY, MM, DD (one byte each)
                  "L" .   # Number of records in file
                  "S" .   # Length of header structure
                  "S" .   # Length of each record
                  "a20";  # 20 bytes that we don't care about

# Perl pack/unpack format representing the structure of each field descriptor
# (the 2nd-Nth 32-byte chunk):
$DBF_field_desc_fmt = "A11" .  # Field name in 0-terminated ASCII
                      "a" .  # Field type in ASCII
                      "L" .  # Field address in memory (unused)
                      "C" .  # Field length (binary)   \___/ these 2 bytes can also be a 2-byte field length,
                      "C" .  # Decimal count (binary)  /   \ 1-65535, for field type 'C' in Foxbase & Clipper.
                      "C" .  # Field flags (FoxPro/FoxBase only)
                      "a1" .  # reserved
                      "C" .  # Work area ID
                      "a2" .  # reserved
                      "C" .  # Flag for SET FIELDS
                      "a7" . # reserved
                      "A";   # Index field flag

# For the meanings of the template letters, see Perl documentation
# (e.g., on Linux do 'man perlfunc' then read 'pack')

# Unfortunately, the "v" & "V" template characters (Vax-byte-order integers)
# are poorly documented: the Perl docs suggest that they are signed, but they
# seem to be unsigned on my x86 machines.  The "S" & "L" template characters
# (machine-order unsigned integers) won't work right on big-endian machines.
# So we do the best we can: on big endian machines we change the 'S' template
# characters to 'v' and the 'L' template character to 'V'.  That'll work 99.9%
# of the time -- i.e., as long as the record length doesn't exceed 32K, or
# the v and V templates are unsigned.
# Thanks to John McVeagh (who uses AIX) for inspiring this.
if ($big_endian) {
   $DBF_header_fmt =~ s/LSS/Vvv/;
   print "Note: This is a big-endian machine.  Adjusting template.\n";
}

# $cvt_failed is a side-effect result of &cvt1file.
$cvt_failed = 0;  # will be set to 1 iff cvt1file failed, or 0 for success

# handy constant
$zerobyte = "\0";  # same as pack("c",0), or in Perl 5 it could also be chr(0)


# use the '-ta' or '-tu' option to adjust $translate and $garde_accent

# By Jacky Bruno...
# The file can have accentued characters coded in DOS pc style (where, for example "�"
# is coded "82h") or coded in ANSI style (linux or Windows) ( "�" is coded "E9h")
# If codage is already ANSI, no need to re-code it: put $translate to 0
# If codage is pc, you can choose to re-code or let codage the way it is.
# Accent codage change? codage pc --> codage this way:
# 1  -> yes, let's change codage (another number is possible)
# 0  -> no, let's keep the codage the way it is in the original file
$translate=0;

# If codage is changed ($translate=1), do we keep accentued characters?
# Translation keeping or not accentued characters
# 1  -> keeping accentued characters (or another number)
# 0  -> don't keep accentued characters
$garde_accent=1;  #In french: keep = garde

# Conversion tables codage pc <--> codage ansi for accentued characters
# They can be completed regarding the "correspondances"
# (every character must respect the same order in every codage)
$code_pc="\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a".
         "\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94".
         "\x95\x96\x97\x98\x99\x9a\xa0\xa1\xa2\xa3".
         "\xa4\xa5\xb5\xb6\xb7\xc6\xc7\xd2\xd3\xd4".
         "\xd5\xd6\xd7\xd8\xe0\xe1\xe2\xe3\xe4\xe5".
         "\xe9\xea\xeb\xec\xed";
$code_ansi="����������".
           "����������".
           "����������".
           "����������".
           "i���������".
           "�����";
$code_brut="ueaaaaceee".
           "iiiAAEeEoo".
           "ouuyOUaiou".
           "nNAAAaAEEE".
           "iIIIOSOOoO".
           "UUUyY";

$silent = 0;  # a flag we sometimes set to avoid redundant warning messages

####################################
###  end of global variables
####################################


# Given the version number found in the header of a .dbf file, return our
# best guess for the name of the product which created the .dbf file
sub productName {
   local($product);
   if (2 == $verNum) {
      $product = "(FoxBase)";
   } elsif (3 == $verNum) {
      $product = "(File without DBT)";
   } elsif (4 == $verNum) {
      $product = "(dBASE IV w/o memo file)";
   } elsif (5 == $verNum) {
      $product = "(dBASE V w/o memo file)";
   } elsif (0x30 == $verNum) {  # 48
      $product = "(Visual FoxPro)";
   } elsif (0x31 == $verNum) {  # 49
      $product = "(Visual FoxPro w/ AutoIncrement field)";
   } elsif (0x7B == $verNum) {  # 123
      $product = "(dBASE IV w/ memo file)";
   } elsif (0x83 == $verNum) {  # 131
      $product = "(File w/ DBT, or dBASE III+ w/ memo file)";
   } elsif (0x8B == $verNum) {  # 139
      $product = "(dBASE III or IV w/ memo file)";  # microsoft says it is dBase III, but http://www.e-bachmann.dk/docs/xbase.htm says it is dBase IV
   } elsif (0x8E == $verNum) {  # 142
      $product = "(dBASE IV w/ SQL table )";
   } elsif (0xE5 == $verNum) {  # 229
      $product = "(Clipper SIX w/ SMT memo file)";
   } elsif (0xE6 == $verNum) {  # 230
      $product = "\nWarning: Encrypted Clipper SIX database, probably can't be handled\n";
   } elsif (0xF5 == $verNum) {  # 245
      $product = "(FoxPro w/ memo file)";
   } elsif (0xFB == $verNum) {  # 251
      $product = "(FoxPro ???)";
   } else {
      $product = "(unknown xBase database program [perhaps Alpha4/Alpha5, dBFast, DataBoss, CodeBase, or Lotus Approach], please contact Dave Burton at http:\\\\www.burtonsys.com\\email\\)";
   }
   return $product;
} #productName


# globals used by &fetch_memo
$current_dbf_file = '';
$current_memo_file = '';
$current_memo_file_is_open = 0;
$current_memo_file_size = 0;
$current_memo_file_blocksize = 0;  # will be changed to 512 or 64 or whatever
$null_memo_count = 0;
$real_memo_count = 0;


# Retrieve a memo from a FoxPro .FPT memo file.  Input is the block number.
# MEMOFILE must already be open, and globals $current_memo_file* must already
# be set.
sub fetch_fpt_memo {
   local($blocknum) = shift;
   local($fbuf) = '';
   local($fileofs) = $blocknum * $current_memo_file_blocksize;
   if (($fileofs+8) >= $current_memo_file_size) {
      printf "ERROR: block $blocknum (offset $fileofs) of '$current_memo_file' is past EOF.\n";
      return '';
   }
   seek( MEMOFILE, $fileofs, 0 );
   if (!sysread(MEMOFILE, $fbuf, 8)) {
      print "ERROR: Could not read '$current_memo_file' at ofs=$fileofs, $!\n";
      return '';
   }
   local($memotype, $memolen) = unpack( "NN", $fbuf );
   # 'N' is 4-byte big-endian integer
   if (($memotype < 0) || ($memotype > 2)) {
      print "Warning: unrecognized Memo type $memotype for Memo block $blocknum\n" .
            "(offset $fileofs) in '$current_memo_file'.\n";
   }
   if ($memolen < 0) {
      print "Warning: bad Memo file '$current_memo_file', memo block $blocknum has\n" .
            "negative size.\n";
   }
   if ($memolen <= 0) {
      return '';
   }
   if (($memolen + $fileofs + 8) > $current_memo_file_size) {
      local($newlen) = $current_memo_file_size - ($fileofs + 8);
      print "Warning: bad Memo file '$current_memo_file', memo block $blocknum is\n" .
            "incomplete (truncated from $memolen to $newlen bytes)\n";
      $memolen = $newlen;
   }
   $fbuf = '';
   if (!sysread(MEMOFILE, $fbuf, $memolen)) {
      print "ERROR: could not read $memolen-byte memo from '$current_memo_file'\n" .
            "at block $blocknum (offset $fileofs)\n";
   }
   return $fbuf;
} #fetch_fpt_memo


# read MEMOFILE (assumed to be an open .DBT file), and determine the BLOCKSIZE
sub fetch_dbt_blocksize {
   local($mbuf, $blksiz);
   $blksiz = 0;
   seek( MEMOFILE, 16, 0 );
   $mbuf = "\1";
   if (!sysread(MEMOFILE, $mbuf, 1)) {
      print "ERROR: Could not read '$current_memo_file' at ofs=16, $!\n";
   } else {
      if ($mbuf eq $zerobyte) {
         # dBase IV, supports variable BLOCKSIZE
         seek( MEMOFILE, 20, 0 );
         $mbuf = "\0\0";
         sysread(MEMOFILE, $mbuf, 1);
         $blksiz = unpack( "v", $mbuf );
         # "v" means 2-byte little-endian integer
         if (1 == $current_memo_file_blocksize) {
            # dBase III format memo file created by dBase IV ?
            $blksiz = 512;
         } elsif ($current_memo_file_blocksize < 0) {
            # fix overflow for blocksize 32768 (maybe not possible anyhow)
            $blksiz += 65536;
         }
         if (! $blksiz) {
            print "ERROR: '$current_memo_file' is not a valid dBase IV memo file (no blocksize\n" .
                  "found at file offset 20).\n";
         }
      } elsif ($mbuf eq "\3") {
         # dBase III+, always uses 512-byte BLOCKSIZE
         $blksiz = 512;
      } else {
         # unrecognized file format
         print "ERROR: '$current_memo_file' is an unrecognized xBase memo file format\n";
      }
   }
   return $blksiz;
} #fetch_dbt_blocksize


# read MEMOFILE (assumed to be an open .FPT file), and determine the BLOCKSIZE
sub fetch_fpt_blocksize {
   local($mbuf, $blksiz);
   $blksiz = 0;
   seek( MEMOFILE, 6, 0 );
   $mbuf = "\0\0";
   if (!sysread(MEMOFILE, $mbuf, 2)) {
      print "ERROR: Could not read '$current_memo_file' at ofs=6, $!\n";
      return 0;
   } else {
      $blksiz = unpack( "n", $mbuf );
      # "n" means 2-byte big-endian integer
      if (! $blksiz) {
         print "ERROR: '$current_memo_file' is not a valid FoxPro memo file (no blocksize\n" .
               "found at file offset 6).\n";
      }
   }
   return $blksiz;
} #fetch_fpt_blocksize


# Input is name of .dbf file (not the memo file!), and the memo block number.
# Returns the memo in a string.
# The memo file can be a .dbt file or a .fpt file.  This subroutine would look
# for both (except that .dbt file support isn't yet implemented).
# If the .dbf file name is '', then current memo file is closed, '' is
# returned, and nothing else is done.
# If the block number is zero, then '' is always returned.
# If .dbf file name has changed since last time, the old memo file is closed,
# and the new one is opened.
# If the memo file can't be read, then a string is returned containing the
# block number preceeded by '#'.
sub fetch_memo {
   local( $dbf_file, $blocknum ) = @_;
   local( $result ) = '';
   local( $mbuf );
   if (($dbf_file ne $current_dbf_file) && $current_memo_file_is_open) {
      if ($debugmode) {
         print "dbg: Closing '$current_memo_file' (memo file for '$current_dbf_file').\n";
      }
      close MEMOFILE;
      $current_memo_file_is_open = 0;
      $current_memo_file_size = 0;
      $current_memo_file_blocksize = 0;
      $null_memo_count = 0;
      $real_memo_count = 0;
   }
   if (('' eq $dbf_file) || (0 == $blocknum)) {
      return '';
   }
   if (($dbf_file ne $current_dbf_file)) {
      $current_dbf_file = $dbf_file;
      $current_memo_file = '';
      # figure out name of memo file
      $fpt_file = $dbf_file;
      $fpt_file =~ s/\.DBF$/.FPT/;
      $fpt_file =~ s/\.dbf$/.fpt/i;
      $dbt_file = $dbf_file;
      $dbt_file =~ s/\.DBF$/.DBT/;
      $dbt_file =~ s/\.dbf$/.dbt/i;
      if ($fpt_file eq $dbt_file) {
         printf "ERR: '$dbf_file' is not the name of a .DBF file\n";
         return '?';
      }
      if (-f $fpt_file) {
         $current_memo_file = $fpt_file;
      } elsif (-f $dbt_file) {
         $current_memo_file = $dbt_file;
      }
      # open memo file
      if ('' ne $current_memo_file) {
         if (!open( MEMOFILE, $current_memo_file )) {
            print "ERROR: Could not open '$current_memo_file', $!\n";
         } else {
            $current_memo_file_is_open = 1;
         }
      } else {
         print "ERROR: Memo file $dbt_file or $fpt_file not found.\n";
      }

      # next figure out the SET BLOCKSIZE setting:
      if ($current_memo_file_is_open) {
         # We must read the memo file in binary mode (avoid translations of end-lines)
         binmode MEMOFILE;
         # get size of memo file
         $current_memo_file_size = -s MEMOFILE;
         if ($current_memo_file eq $dbt_file) {
            # .DBT file
            $current_memo_file_blocksize = &fetch_dbt_blocksize;
         } else {
            # .FPT file
            $current_memo_file_blocksize = &fetch_fpt_blocksize;
         }
         if ($current_memo_file_blocksize < 0) {
            # fix overflow for blocksize 32768 (maybe not possible anyhow)
            $current_memo_file_blocksize += 65536;
         }
         if (0 == $current_memo_file_blocksize) {
            close MEMOFILE;
            $current_memo_file_is_open = 0;
            # error message was displayed by fetch_dbt_blocksize or fetch_fpt_blocksize
         }
         if ($current_memo_file_is_open) {
            print "Opening memo file '$current_memo_file' for '$dbf_file', block size = $current_memo_file_blocksize.\n";
         }
      }

      if ($current_memo_file =~ /\.dbt$/) {
         print "ERROR: This program doesn't yet understand .DBT (memo) files.  If you can\n" .
               "furnish me with some test files, I might be able to add support for you.\n" .
               "Email me via http\://www.burtonsys.com/email/\n";
         if ($current_memo_file_is_open) {
            close MEMOFILE;
            $current_memo_file_is_open = 0;
         }
      }
      if (! $current_memo_file_is_open) {
         print "Warning: memo fields will be converted as block numbers, rather than the\n" .
               "actual memo text.\n";
      }
   }
   if (! $current_memo_file_is_open) {
      return '#' . $blocknum;
   }

   # Fetch the memo from the memo file
   if ($current_memo_file =~ /\.dbt$/) {
      # not currently implemented
      $result = &fetch_dbt_memo( $blocknum );
   } else {
      $result = &fetch_fpt_memo( $blocknum );
   }
   if ('' eq $result) {
      $null_memo_count++;
   } else {
      $real_memo_count++;
   }
   return $result;
} #fetch_memo


# Jdate2Cal converts a 4-byte integer Julian Date to YYYY-MM-DD string.
# The code was cribbed (with minor modifications) from sub CalDate in CalDate.pm from
# http://sourceforge.net/projects/jday/files/jday/2.4/jday-2.4.tar.gz (which is copyrighted code), and
# used in this uncopyrighted program by the gracious permission of author Hiram Clawson (jday at hiram.ws):
# "Good Afternoon David: Please feel free to use the code snippet as you desire. --Hiram"  5/23/2012
sub Jdate2Cal {
   local($jd, $ka, $ialp, $kb, $kc, $kd, $ke, $day, $month, $year, $result);
   $jd = shift;  # integer julian date
   $jd = int($jd);
   $ka = $jd;
   if ( $jd >= 2299161 ) {
      $ialp = int(( $jd - 1867216.25 ) / ( 36524.25 ));
      $ka = int($jd + 1 + $ialp - ( $ialp >> 2 ));
   }
   $kb = int($ka + 1524);
   $kc = int(( $kb - 122.1 ) / 365.25);
   $kd = int($kc * 365.25);
   $ke = int(( $kb - $kd ) / 30.6001);

   $day = $kb - $kd - int( $ke * 30.6001 );

   if ($ke > 13) {
      $month = int($ke - 13);
   } else {
      $month = int($ke - 1);
   }

   if ( ($month == 2) && ($day > 28) ) {
      $day = 29;
   }

   if (($month == 2) && ($day == 29) && ($ke == 3)) {
      $year = int($kc - 4716);
   } elsif ($month > 2) {
      $year = int($kc - 4716);
   } else {
      $year = int($kc - 4715);
   }

   # local($dayofweek) = int(($jd + 1) % 7);
   # local($dayofyear)
   # if ( $year == (($year >> 2) << 2) ) {
   #    $dayofyear =
   #            int( ( 275 * $month ) / 9)
   #            - int(($month + 9) / 12)
   #            + $day - 30;
   # } else {
   #    $dayofyear =
   #            int( ( 275 * $month) / 9)
   #            - ((($month + 9) / 12) << 1)
   #            + $day - 30;
   # }

   # $result = $year . '-' . $month . '-' . $day;
   $result = sprintf( "%04d-%02d-%02d", $year, $month, $day );
   return $result;
} # Jdate2Cal


# sanity tests
$tmp1 = &Jdate2Cal(2455958);
if ($tmp1 ne "2012-01-31") {
   print "ERROR: Jdate2Cal(2455958) = '" . $tmp1 . "' but it should be '2012-01-31'\n";
}
$tmp1 = &Jdate2Cal(2299161);
if ($tmp1 ne "1582-10-15") {
   print "ERROR: Jdate2Cal(2455958) = '" . $tmp1 . "' but it should be '1582-10-15'\n";
}


# Read infile (name of a .DBF file) and create outfile (name of a .CSV file).
sub cvt1file {
   local( $infile, $outfile ) = @_;
   local( $recnum ) = 0;
   local( $skipped ) = 0;
   local( $offset_of_0 );
   local( $buf ) = "";
   local( $reclens_look_right ) = 0;
   local( $offsets_match_fieldlens );
   local( $i );
   local( @tmp, $tmp, $tmp1 );
   local( $has_memo_fields ) = 0;  # are there any 'M' fields (fields that use the memo file)?
   local( $date, $time, $hr, $min, $sec );

   $cvt_failed = 0;  # side-effect result, 0 or 1

   # open dbf file
   if (!open( DBF, $infile )) {
      &show_progversion;
      print "ERROR: Could not open '$infile', $!\n";
      $cvt_failed = 1;
      return 0;  # no records converted
   }
   # We must read the input .dbf file in binary mode (avoid translations of end-lines)
   binmode DBF;

   # get size of .dbf input file
   $DBF_file_size = -s DBF;

   # Remove old output file if it exists
   unlink $outfile;  # mostly in case outfile is on a buggy MARS_NWE volume, so we don't get trailing junk in the output file if it already existed and was bigger than the new output file

   if (!sysread(DBF, $buf, 32)) {
      &show_progversion;
      print "ERROR: Could not read first 32 bytes from '$infile', $!\n";
      $cvt_failed = 1;
      return 0;  # no records converted
   }

   # Unpack the file header fields from the first 32 bytes of the .dbf file
   # The $DBF_header_fmt template is defined above
   ( $verNum, $yy, $mm, $dd, $numrecs, $hdrLen, $recLen ) = unpack( $DBF_header_fmt, $buf );

   $might_be_dBase7 = (4 == (7 & $verNum));
   if ($debugmode) {
      print "dbg[1]: might_be_dBase7 = $might_be_dBase7\n";
   }
   if (($hdrLen % 48) != 21) {
      $might_be_dBase7 = 0;
   }
   if ($debugmode) {
      print "dbg[2]: might_be_dBase7 = $might_be_dBase7, (hdrLen%48)=" . ($hdrLen % 48) . "\n";
   }

   print "version=$verNum ";
   $product = &productName( $verNum );
   if ($might_be_dBase7) {
      $product = "(dBASE IV w/o memo file, or perhaps dBase 7)"
   }
   if ("" ne $product) {
      print "$product ";
   }
   if ($yy < 78) {  # The first .dbf file was created 1/29/1978, so it can't be older than that
      # Microsoft leaves off the 100, so fix it:
      $yy += 100;
   }
   printf " yyyy/mm/dd=%04d/%02d/%02d\n", ($yy+1900),$mm,$dd;
   # printf " jj/mm/aa=%02d/%02d/%02d\n", $dd,$mm,$yy;  # -- French (by Jacky Bruno) --
   print "numrecs=$numrecs";
   # print "nombreEnregValides=$numrecs";  # -- French (by Jacky Bruno) --
   $calculated_numrecs = int(($DBF_file_size - $hdrLen) / $recLen);
   print ", calculated numrecs=$calculated_numrecs.\n";
   if ($numrecs != $calculated_numrecs) {
      print "ERROR: numcres from header unequal to calculated number of records.\n";
      if ($calculated_numrecs < $numrecs) {
         print "$infile might be incomplete.\n";
      } else {
         printf "Final %d records are suspect.\n", $calculated_numrecs-$numrecs;
      }
   }
   print "hdrLen=$hdrLen  ";
   # print "hdrLong=$hdrLen  ";  # -- French (by Jacky Bruno) --
   print "recLen=$recLen  ";
   # print "enregLong=$recLen  ";  # -- French (by Jacky Bruno) --
   $numfields = int(($hdrLen - 1) / 32) - 1;

   if ($might_be_dBase7) {
      $db7numfields = int(($hdrLen - 69) / 48);
      print " numfields = $numfields per record (or $db7numfields per record if this is a dBase 7 file).\n";
   } else {
      print " numfields = $numfields per record.\n";
   }

   # print "nombreChamps=$numfields (by record)\n";  # -- French (by Jacky Bruno) --
   $extra_hdr_bytes = ($hdrLen - (1+(($numfields+1)*32)));
   if ($extra_hdr_bytes != 0) {
      if ((48 == $verNum) && (7 == $extra_hdr_bytes)) {  # Visual FoxPro idiosyncracy
         print "Visual FoxPro idiosyncracy: 7 extra header bytes (ignored)\n";
      } else {
         print "Warning: non-standard .dbf file format, header contains $extra_hdr_bytes extra byte(s).\n";
      }
   }
   if ($might_be_dBase7) {
      # Looks like dBase 7
      # dBase 7 is a very different format, with 48-byte (instead of 32-byte) field
      # definition headers; see http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm
      # The header of a dBase 7 file has 36 extra header bytes (mostly the Language
      # driver name), plus 16 extra bytes per field descriptor, plus the Field
      # Properties Structure (which I think is at least 16 bytes)
      print "Warning: $infile might be a dBase 7 file!  This tool does not support dBase 7.\n";
   }
   $extra_file_bytes = ($DBF_file_size - ($hdrLen + ($calculated_numrecs * $recLen)));
   if ($extra_file_bytes > 0) {
      print "Warning: $infile contains $extra_file_bytes extra byte(s) at the end (ignored).\n";
   }

   # $recfmt will be the unpacking template for each record.
   # This template will be build by reading field's definitions
   # (32 bytes per field starting at the 33rd byte of the file)
   $recfmt = "A";  # first byte of each record is the "deleted" indicator byte (normally blank)

   # We will build arrays containing fields caracteristics
   # (name, type, width, offset).

   # The [0] array entries are for the "deleted" indicator byte:
   $fld_nam[0] = '';
   $fld_ofs[0] = 0;
   $fld_len[0] = 1;
   $fld_typ[0] = 'C';
   $fld_flg[0] = 0;
   $fld_supported[0] = 1;

   $running_offset = 1;  # 1, not 0, because the "deleted" indicator is 1 byte

   # read all the field definition headers (32 bytes each):

   for ($i=1; $i <= $numfields; $i++) {
      if (!sysread(DBF, $buf, 32)) {
          print "ERROR: Could not read field definition header for field $i from '$infile', $!\n";
          $cvt_failed = 1;
          return 0;  # exit with error
       }

      # Unpack field definition using $DBF_field_desc_fmt template (we keep
      # only the first 5 fields):
      ( $fldName, $fldType, $fldOffset, $fldLen, $decCnt, $fldFlags ) = unpack( $DBF_field_desc_fmt, $buf );

      # I don't know why the dumb A11 format doesn't strip the garbage after
      # the 0-byte, but it doesn't.  The Perl documentation says, "When
      # unpacking, 'A' strips trailing spaces and nulls," but that apparently
      # doesn't mean that it truncates at the first null byte.  We could use
      # "Z11" instead of "A11" if we didn't care about Perl 4 compatibility.
      # Most .dbf files don't have trailing garbage after the 0-byte, anyhow,
      # but some do.  This is for those .dbf files.
      $offset_of_0 = index($fldName, $zerobyte);
      if (-1 != $offset_of_0) {
         $fldName = substr( $fldName, 0, $offset_of_0 );
      }

      # Some xBase variants (Clipper, Foxbase, perhaps others) permit
      # character data fields larger than 255 characters, using the
      # "Decimal Count" field as a high length byte.  (Thanks to Jeff
      # Price <jeff.price@rocketmail.com.nospam> for telling me this.)
      if (($decCnt > 0) && ('C' eq $fldType) && ($recLen >= (256 * $decCnt))) {
         $fldLen += (256 * $decCnt);
      }

      $fldName =~ s/\r/ /g;  # change "\rtastrade.d" to " tastrade.d" to avoid messing up display
      if ($debugmode) {
         printf "%3d: %-10s type='%s' offset=%d fldLen=%d, fldFlags=0x%02x\n",
                $i, $fldName, $fldType, $fldOffset, $fldLen, $fldFlags;
      }
      $fld_nam[$i] = $fldName;
      $fld_ofs[$i] = $fldOffset;
      $fld_len[$i] = $fldLen;
      $fld_typ[$i] = $fldType;
      $fld_flg[$i] = $fldFlags;

      # Add another field to the template, type 'A' (text completed by spaces) with $fldLen width
      if ((('I' eq $fldType) || ('+' eq $fldType)) && (4 == $fldLen)) {
         # Two special cases:
         # 'I' is FoxPro or dBase 7 binary 4-byte integer.  For FoxPro, it is known to be little-endian; I dunno about dBase 7.  For dBase, it is known to be signed; I presume that is also true for FoxPro.
         # '+' is a dBase 7 "Autoincrement" field, stored the same as a long (see http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm)
         if ($big_endian) {
             $recfmt .= "V";  # probably unsigned, unfortunately
         } else {
             $recfmt .= "l";  # signed
         }
      } elsif (('M' eq $fldType) && (4 == $fldLen)) {
         # Another special case:
         # 'M' is a Memo field -- the data is in another file, this is a block
         # number referencing the other file.  Some databases use a 10-byte
         # string to store the block number, others use 4 binary bytes.  So
         # if the length is 4, we decode it as unsigned binary.
         if ($big_endian) {
             $recfmt .= "V";  # probably unsigned
         } else {
             $recfmt .= "L";  # definitely unsigned
         }
      } elsif (('B' eq $fldType) && (8 == $fldLen)) {
         # 8-byte Foxbase/Foxpro double-precision binary (IEEE 64-bit floating pt).
         # Stored 52-bit mantissa LSB first, then 11-bit exponent & 1-bit sign.
         # Thanks to Roland Baranyai for the sample data!
         if ($perl_supports_IEEE754_doubles) {
            $recfmt .= "d";
         } else {
            $recfmt .= "a8";
            if (!$warned_about_B_field) {
               print "Warning: Foxpro 'B' (double-precision) fields won't be converted correctly\n"
                   . "because this Perl doesn't support FoxPro's little-endian IEEE-754 64-bit\n"
                   . "data format.  For help, contact Dave Burton at http:\\\\www.burtonsys.com\\email\\\n";
               $warned_about_B_field = 1;
               # It is quite possible that on big-endian computers this fails
               # but could be made to work by simply reversing the byte order.
               # But I don't have the ability to test it.
            }
         }
      } elsif (('T' eq $fldType) && (8 == $fldLen)) {
         # 8-byte Foxpro date/time field
         $recfmt .= "a8";  # Note: a8 preserves zero bytes, A8 truncates them, apparently
      } else {
         # Normal fields:
         $recfmt .= "A$fldLen";
      }

      $running_offset += $fldLen;
   } #for
   # The $recfmt unpacking template is complete

   # This is a hack for Visual Foxpro.  For some reason, Visual Foxpro
   # often (always?) puts 8 junk field definition headers after the real
   # ones.  All 8 always have zero length.  The last 7 always have null names,
   # types & offsets, too; the first of the eight sometimes has a null name,
   # type & offset, but sometimes has the name "\rtastrade.d" with type='b'
   # offset=99 (where 99 is character code 'c').  That seems to have something
   # to do with a Microsoft test file called "tastrade.dbc".  Anyhow, when
   # we encounter this, we just ignore the 8 bogus field definitions:
   if ($numfields > 8) {
      if (  (0==$fld_len[$numfields]) && (0==$fld_len[$numfields-1])
          && (0==$fld_len[$numfields-2]) && (0==$fld_len[$numfields-3])
          && (0==$fld_len[$numfields-4]) && (0==$fld_len[$numfields-5])
          && (0==$fld_len[$numfields-6]) && (0==$fld_len[$numfields-7])
          && (0 != $fld_len[$numfields-8])) {
         if (  ('' eq $fld_nam[$numfields]) && ('' eq $fld_nam[$numfields-1])
             && ('' eq $fld_nam[$numfields-2]) && ('' eq $fld_nam[$numfields-3])
             && ('' eq $fld_nam[$numfields-4]) && ('' eq $fld_nam[$numfields-5])
             && ('' eq $fld_nam[$numfields-6]) && ('' ne $fld_nam[$numfields-8])) {
            print "Visual FoxPro idiosyncracy: 8 bogus 0-length fields (ignored)\n";
            $numfields -= 8;
            splice( @fld_nam, $numfields+1, 8 );  # discard last 8 array elements
            splice( @fld_ofs, $numfields+1, 8 );
            splice( @fld_len, $numfields+1, 8 );
            splice( @fld_typ, $numfields+1, 8 );
            splice( @fld_flg, $numfields+1, 8 );
            $recfmt = substr( $recfmt, 0, length($recfmt)-16 );  # remove the "A0A0A0A0A0A0A0A0" from the end
         }
      }
   }

   if ($debugmode) {
      printf "recfmt='%s'\n", $recfmt;
   }

   # Classify each field as supported or unsupported
   for ($i=1; $i <= $numfields; $i++) {
      $fldType = $fld_typ[$i];
      $fld_supported[$i] = 0;
      if (index("CDLNIMFBT",$fldType) >= 0) {
         $fld_supported[$i] = 1;
         if ((8 != $fld_len[$i]) && (('B' eq $fldType) || ('T' eq $fldType))) {
            # 'B' and 'T' are only supported if they are 8 bytes long
            $fld_supported[$i] = 0;
         }
      }
      if ('M' eq $fldType) {
         $has_memo_fields = 1;  # optimization
      }
   } #for

   # Lukasz Matusiak (lukaszzp at gmail.com) provided me 21-May-2012 with the
   # sample data I needed to support FoxPro's 'T' filed (DateTime).  So I
   # changed "CDLNIMFB" to "CDLNIMFBT" above.  Thanks, Lukasz!

   # "Dan" (mail_lodge at yahoo.com.au) emailed me 19-Jul-2005 to say
   # that type 'F' fields work fine.  They are just text representations of
   # floating point numbers, such as "1.97056329250e+000" (that example is
   # from Dan's email, and it has a field length = 19).  According to
   #   http://www.dbase.com/KnowledgeBase/int/db7_file_fmt.htm
   # type 'F' fields contain "Number stored as a string, right justified, and
   # padded with blanks to the width of the field" in dBase 7, which is
   # consistent with Dan's report.  So I changed "CDLNIM" to "CDLNIMF" above.

   # type 'B' is IEEE-754 double-precision (8-byte) floating point, in FoxPro.
   # Thanks to Roland Baranyai for the sample data from which I determined this!
   # If this Perl supports that data type via the 'd' unpack template, then
   # we handle this well.  Otherwise, we just represent it as hexidecimal
   # in the output file (and display a warning).

   # Jacky Bruno comments...
   # Definition of output format
   # Here will be used the field separator
   # (defined by $separe variable modifiable at the beginning of the file)
   # You can change quotes used at the left and the right of fields too
   # using another character (is it really useful?) by changing " in the
   # next variable to the wished character (you can even set a beginning
   # character and a ending character) example :
   #   $csvoutfmt = 'Y%sZ' . ("${separe}Y%sZ" x ($numfields-1)) . "\n";
   # field names will have Y before and Z after : Yname_of_fieldZ
   # Attention to escape special characters if used
   # The () tells that ${separe}"%s" will be repeated ($numfields-1) times

   # If there were no questionable data fields, this would suffice:
   # $csvoutfmt = '"%s"' . ("${separe}\"%s\"" x ($numfields-1)) . "\n";
   # This does the same thing, except that it adds '?' to questionable data fields:
   $csvoutfmt = '';
   for ($i=1; $i <= $numfields; $i++) {
      if ($i > 1) {
         $csvoutfmt .= $separe;
      }
      if ($fld_supported[$i]) {
         $csvoutfmt .= '"%s"';
      } else {
         $csvoutfmt .= '"%s?"';
      }
   }
   $csvoutfmt .= "\n";
   # note: we started counting with $i=1 instead of 0 because the DelFlg field
   # won't be output

   if ($jsonmode) {
      $outfmt = '{';
      for ($i=1; $i <= $numfields; $i++) {
         if ($i > 1) {
            $outfmt .= ", ";
         }
         $outfmt .= ('"' . $fld_nam[$i] . '":"%s"');
      }
      $outfmt .= "}";
   } else {
      $outfmt = $csvoutfmt;
   }

   if ($running_offset != $recLen) {
      print "Warning: Summed field lengths (+1 byte for DEL flag) = $running_offset, which is unequal to recLen.\n";
      $reclens_look_right = 0;
   } else {
      print "summed field lengths + 1 = $running_offset = recLen (as expected).\n";
      $reclens_look_right = 1;
   }

   ### Begin code to fix field offsets for .dbf files in which the field
   ### offsets are incorrect or missing altogether

   # Are two or more fields at the same field offset?  If so then the .dbf
   # file definitely doesn't have correct field offsets in the header.
   $prev_fldOffset = $fld_ofs[1];
   $cnt_idential_fldOffsets = 0;
   for ($i=2; $i <= $numfields; $i++) {
      $fldOffset = $fld_ofs[$i];
      if ($fldOffset == $prev_fldOffset) {
         $cnt_idential_fldOffsets++;
      }
      $prev_fldOffset = $fldOffset;
   } #for

   # Tell the user about the identical field offsets
   if ($cnt_idential_fldOffsets > 0) {
      $cnt_idential_fldOffsets++;
      print "Warning: ";
      if ($cnt_idential_fldOffsets == $numfields) {
         print "All ";  # say "All nn fields have identical offsets."
      }
      print "$cnt_idential_fldOffsets fields have identical offsets.\n";
      $silent = 0;
      if ($cnt_idential_fldOffsets == $numfields) {
         print "Note: $infile is in a non-standard .dbf format (such as Alpha-4's),\n" .
               "in which the field offsets are missing from the header.\n" .
               "The offsets will be recalculated from the summed field lengths.\n";
         # Mark Godhelf reported that for his Alpha-4's .dbf files $fldOffset is always zero.  12/13/2002
         # Stephane Boireau had a .dbf file in which all the $fldOffsets were 383.  4/13/2003
         $silent = 1;
      }
   }

   # Check whether or not the field offsets are consistent with the field lengths,
   # and if they are not then tell the user about the problem (unless we already
   # told him that all the field offsets are identical).
   $running_offset = 1;
   $offsets_match_fieldlens = 1;
   for ($i=1; $i <= $numfields; $i++) {
      $fldLen = $fld_len[$i];
      $fldOffset = $fld_ofs[$i];
      if (($running_offset != $fldOffset) && !$silent) {
         print "ERROR: field $i (len=$fldLen): running calculated offset, $running_offset, does not match field offset from header, $fldOffset.\n";
         $offsets_match_fieldlens = 0;
      }
      $running_offset += $fldLen;
   } #for

   if ((!$offsets_match_fieldlens) && ($reclens_look_right || ($cnt_idential_fldOffsets > 0))) {
      # fix the field offsets by calculating them from the summed field lengths
      if (!$silent) {
         print "The offset(s) will be recalculated from the summed field lengths.\n";
      }
      $running_offset = 1;
      for ($i=1; $i <= $numfields; $i++) {
         $fldLen = $fld_len[$i];
         $fld_ofs[$i] = $running_offset;
         $running_offset += $fldLen;
      } #for
   }

   ### End of code to fix field offsets

   # Read last byte of header (at the end of fields definitions), which should be CR (0x0D)
   if (!sysread(DBF, $buf, 1)) {
      print "ERROR: Could not read terminator byte from '$infile', $!\n";
      $cvt_failed = 1;
      return 0;  # no records converted
   }
   if ("\r" ne $buf) {
      if ((48 == $verNum) && ($zerobyte eq $buf))  {  # Visual FoxPro generates databases with this minor flaw
         printf "Visual FoxPro idiosyncracy:";
      } else {
         print "ERROR:";
      }
      printf " Header-terminator byte at offset %d is 0x%02x (it should be 0x0D)\n", $hdrLen-1, ord($buf);
   } elsif ($extra_hdr_bytes) {
      printf "Header-terminator byte is 0x%02x (as expected).\n", ord($buf);
   }
   if ($extra_hdr_bytes) {
      # Usually the header is correctly followed by data records.
      # But sometimes it isn't right. Sometimes there is a 0 byte,
      # sometimes there is a field that tells the link to a file.
      # Stephane Boireau had a .dbf file in which a zero byte followed the normal 0x0D terminator byte.  4/13/2003
      if (!sysread(DBF, $buf, $extra_hdr_bytes)) {
         print "ERROR: Could not read the $extra_hdr_bytes extra header bytes from '$infile', $!\n";
         $cvt_failed = 1;
         return 0;  # no records converted
      }
      # Visual Foxpro (verNum 48) always generates 7 extra zero header bytes;
      # for any other circumstance, print them out:
      if (($verNum != 48) || ($buf ne "\0\0\0\0\0\0\0")) {
         print "The $extra_hdr_bytes extra header byte(s) are:";
         for ($i=0; $i<$extra_hdr_bytes; $i++) {
            $tmp = substr($buf, $i, 1);
            printf " 0x%02x", ord($tmp);
         }
         print "\n";
      }
   }

   # Warn about field types that we don't know how to handle
   for ($i=1; $i <= $numfields; $i++) {
      $fldLen = $fld_len[$i];
      $fldOffset = $fld_ofs[$i];
      $fldType = $fld_typ[$i];
      if ((!$fld_supported[$i]) || ((('B' eq $fldType)||('T' eq $fldType)) && (8 != $fldLen))) {
         if ('Y' eq $fldType) {  # don't know how this is represented
            print "Warning: field $i ($fld_nam[$i]) is type '$fldType' (len=$fldLen)";
            if (! defined $fld_typ_seen{$fldType}) {
               print ", which might not\n" .
                  "convert properly (please email Dave via http\://www.burtonsys.com/email/\n" .
                  "and tell him whether it works).";
             }
             # Note: type 'F' fields are now known to work fine.  Search this
             # program for references to 'F' for more comments.  (Thanks, Dan!)
         } else {
            print "Warning: field $i ($fld_nam[$i]) is type '$fldType' (len=$fldLen)";
            if (! defined $fld_typ_seen{$fldType}) {
               print ", which is unsupported.\n" .
                  "If you can tell me how type $fldType fields are stored, or if you are willing to help\n" .
                  "test support for '$fldType' fields, then please email Dave via http\://www.burtonsys.com/email/";
            }
         }
         print "\n";
      }
      $fld_typ_seen{$fldType} = 1;
   } #for

   if (!open( OUTP, ">$outfile" )) {
      print "ERROR: Could not create '$outfile', $!\n";
      $cvt_failed = 1;
      return 0;  # no records converted
   }

   # echo field names to console:
   @tmp = @fld_nam;
   shift @tmp;  # don't output field #0 (the 'deleted' flag)
   foreach $fld (@tmp) {
      # remove leading and trailing whitespace and any embedded quote marks
      $fld =~ s/\s*(\S((.*\S)|)|)\s*/$1/;
      # The aim of this expression before is to take care of fields that have only one letter
      # It can be changed to another expression     $fld =~ s/\s*(\S.*\S)\s*/$1/;
      # but it won't care about one letter long fields
      $fld =~ s/\"/\`/g;  # field names can't contain quote marks
   }

   print "The $numfields fields in each record are named:\n";
   printf $csvoutfmt,@tmp;

   if (('DBWIN' eq substr($tmp[0],0,5)) && $might_be_dBase7) {
      print "ERROR: $infile appears to be a dBase 7 file.  This tool does not support dBase 7 file.\n";
   }

   if ($jsonmode) {
      print OUTP "[\n";
   } else {
      # output field names as first line in output file:
      # Write name fields first in output file
      printf OUTP $csvoutfmt,@tmp;
   }

   $recnum = 0;

   # Then read & convert each record
   while (sysread(DBF, $buf, $recLen)) {
      if ((1 == $extra_file_bytes) && (1 == length($buf))) {
         # For some reason, some .dbf files seem to have an extra ctrl-Z at the end
         if (26 == ord($buf)) {
            print "Trailing ctrl-Z ignored.\n";
         } else {
            printf "Warning: ignored final (extra) character at end of %s: 0x%02x\n", $infile, ord($buf);
         }
         last;
      }

      # in JSON mode, add commas & line-breaks between records
      if ($recnum && $jsonmode) {
         print OUTP ",\n";
      }

      # count records
      $recnum++;
      if ($recnum <= 0) {
         $recnum--;
         print "Warning: more than $recnum records, Perl integer overflow.\n";
         $recnum = 1;
      }

#      if ($recnum > 5000) {
#         last;  # for debugging
#      }

      # Write a dot every 2000 records
      if (0 == ($recnum % 2000)) {
         print '.';
      }

#     if ($buf =~ /\~/) {
#        print "Warning: changed '~' to space in record $recnum\n";
#        $buf =~ tr/\~/ /;
#        if ($buf =~ /\~/) {
#           print "ERR: failed to change '~' to space in record $recnum\n";
#           exit 1;
#        }
#     }

      # Translation of pc codes to ansi (or untranslated) if asked
      if ($translate) {
        if ($garde_accent) {
          eval "\$buf =~ tr /$code_pc/$code_ansi/;"; # Let's keep accentued characters
        } else {
          eval "\$buf =~ tr /$code_pc/$code_brut/;"; # Let's remove accentued characters
        }
      }

      # Unpack record according to $recfmt template
      @fields = unpack( $recfmt, $buf ); # the fields of @fields are record fields

      # fetch 'M' fields from memo file
      if ($has_memo_fields) {
         for ($i=1; $i <= $numfields; $i++) {
            if ('M' eq $fld_typ[$i]) {
               $fields[$i] = &fetch_memo( $infile, $fields[$i] );
            }
         }
      }

      # handle FoxBase's 'B' (8-byte IEEE double-precision float) and 'T' (8-byte Date/Time) fields
      for ($i=1; $i <= $numfields; $i++) {
         if (('T' eq $fld_typ[$i]) && (8 == $fld_len[$i])) {
            # 8-byte Foxpro Date/Time field.
            # First 4 bytes is the Julian Date, where Oct. 15, 1582 = 2299161 just like http://www.nr.com/julian.html
            # Last 4 bytes are the time in milliseconds since midnight.  $recfmt = "a8"
            $tmp = "LL";
            if ($big_endian) {
                $tmp = "VV";  # requires Perl 5
            }
            ( $date, $time ) = unpack( $tmp, $fields[$i] );
            # $tmp = length($fields[$i]);
            # print "dbg: field='" . $fields[$i] . "', len=$tmp, jdate=$date, time=$time, ";
            $date = &Jdate2Cal($date);
            # time is in mSec; convert to sec
            $tmp = int(($time + 500) / 1000);  # sec
            $sec = $tmp % 60;
            $tmp -= $sec;
            $tmp = int(($tmp+30) / 60);  # min
            $min = $tmp % 60;
            $tmp -= $min;
            $hr = int(($tmp+30) / 60);
            $time = sprintf( "%02d:%02d:%02d", $hr, $min, $sec );
            $fields[$i] = $date . ' ' . $time;
            # print "date/time= '" . $date . ' ' . $time . "'\n";
         } elsif (('B' eq $fld_typ[$i]) && (8 == $fld_len[$i])) {
            if ($perl_supports_IEEE754_doubles) {
                $tmp = $fields[$i];
                if ($tmp < 0) { $tmp = -$tmp; }  # Or, in Perl 5, $tmp = abs($fields[$i]);
                if (($tmp > 9007199254740991) || (($tmp != 0) && ($tmp < 0.001))) {
                    # If number isn't represented with at least integer precision,
                    # or if it is a tiny fractional amount, then we might need to
                    # use exponential notation.
                    $tmp = sprintf("%g",$fields[$i]);
                } else {
                    # Otherwise, use regular floating point notation
                    $tmp = sprintf("%f",$fields[$i]);
                }
                # shorten floating point numbers by deleting trailing zeros after
                # the first one (i.e., change "1.00000" to "1.0").
                while ($tmp =~ /^[0-9]+\.[0-9]+0+$/) {
                    chop($tmp);
                }
                $fields[$i] = $tmp;
            } else {
                # if this Perl doesn't support IEEE-754 double-precision, use hexadecimal (ugh!)
                $tmp1 = $fields[$i];
                $tmp = '0x';
                for ($j=7; $j>=0; $j--) {
                   $tmp .= sprintf('%02X',ord(substr($tmp1,$j,1)));
                }
                $fields[$i] = $tmp;
            }
         }
      }

      # debug code -- convert unsupported fields to series of hex bytes from '\x00' to '\xFF'
      for ($i=1; $i <= $numfields; $i++) {
         if (! $fld_supported[$i]) {
            # convert to hexidecimal
            $tmp_unpack_fmt = 'C' . $fld_len[$i];
            @tmp = unpack( $tmp_unpack_fmt, $fields[$i] );
            foreach $ch (@tmp) {
               $ch = '\x' . sprintf( '%02x', $ch );
            }
            $fields[$i] = join( '', @tmp );
            $fields[$i] =~ tr/a-f/A-F/;
         }
      }

      # remove leading and trailing whitespace and any embedded quote marks and newlines and ctrl-Zs
      foreach $fld (@fields) {
         if ($fld =~ /[\s\"]/) {
            $fld =~ s/^\s*//;  # delete leading whitespace
            $fld =~ s/\s*$//;  # delete trailing whitespace
            $fld =~ s/\032/ /g;  # \032 is ctrl-Z; translate it to a space
            if (1==$escape_codes) {
               $fld =~ s/\\/\\\\/g;  # single backslash gets doubled
               $fld =~ s/\r/\\r/g;  # CR turns into \r
               $fld =~ s/\n/\\n/g;  # LF turns into \n
               $fld =~ s/\"/\\"/g;  # quote mark turns into \"
               $fld =~ s/\t/\\t/g;  # tab turns into \t
               $fld =~ s/\f/\\f/g;  # formfeed turns into \f
            } else {
               if (2==$escape_codes) {
                  $fld =~ s/\"/\"\"/g;  # for CSV translate " to "", but I'm unsure every program can handle it
               } else {
                  $fld =~ s/\"/\`/g;  # the old, dumb way: translate " to `
               }
               $fld =~ s/\r\n/ /g;  # translate CR and/or LF to a space
               $fld =~ s/[\r\n]/ /g;
            }
         }
      }

      # Remove the first field (1-byte flag) that tells if the record is
      # deleted (value 2Ah= "*") or valid (value 20h = space, but the space was
      # eliminated above, when we removed leading and trailing whitespace).
      $deleted_flag = shift @fields;

      # If you want to include "deleted" records in the output .csv file, then
      # comment-out the next five lines:
      if ($deleted_flag ne '') {
         $skipped++;
         print "Warning: record $recnum is marked for delete; $skipped records skipped.\n";
         next;
      }
      # write the converted record, using the format built above
      printf OUTP $outfmt,@fields;

   } #while
   if ($jsonmode) {
      print OUTP "\n]\n";
   }
   close OUTP;  # close output file
   close DBF;  # close input file
   if ($recnum >= 2000) {
      print "\n";  # because progress-indicator dots were printed
   }

  # $recnum -= $skipped;  # account for deleted records
  # Hmmmm... Bruno thinks that is needed here, but I don't think so.
  # The question to ask is: does the 'numrecs' field in the .dbf file
  # header include records marked as 'deleted' or not?  I think it should
  # include them, so $recnum shouldn't be decremented by $skipped.

  if ($recnum != $numrecs) {
     print "Warning: file should have had $numrecs records, but actually had $recnum records.\n" .
           "Calculated numrecs=$calculated_numrecs.\n";

     # Since I might be wrong, and Bruno might be right (at least for some
     # database systems), I added the following message:
     if (($recnum-$skipped) == $numrecs) {
        print "Note: The disparity seems to be accounted for by $skipped deleted records.\n" .
              "Please tell Dave Burton via http\://www.burtonsys.com/email/\n";
     }
  }
  return $recnum;
} #cvt1file


$errlevel = 0;

$num_files_processed = 0;

sub do_a_file {
   local( $inFile ) = @_;
   local( $numRecords, $outFile );
   if ($num_files_processed) {
      print "\n";  # separate messages for each file with a blank line
   }
   if ($inFile !~ /\.dbf$/i) {
      printf "ERROR: input file name '$inFile' does not end in '.dbf'\n";
      $errlevel = 2;
   } else {
      # if input file name was upper-case, make output file name upper-case, too
      # (the same in french) si fichier d'entr�e est en majuscules, fichier de sortie en majuscules aussi
      $outFile = $inFile;
      if ($jsonmode) {
         $outFile =~ s/\.dbf$/\.json/i;
      } else {
         $outFile =~ s/\.DBF$/\.CSV/;
         $outFile =~ s/\.dbf$/\.csv/i;
      }

      # Display on the console the file names and number of records
      $num_files_processed++;
      print "Input='$inFile'  Output='$outFile'\n";
      $numRecords = &cvt1file( $inFile, $outFile );
      if ($cvt_failed) {
         $errlevel = 2;
      } else {
         $numRecords++;  # add one for the first record, with the field names in it
         print "Created $outFile from $inFile, $numRecords records.\n";
      }
   }
} #do_a_file


# display a help message; pass 1 as parameter for 'interactive' (shorter) version
sub do_help {
  local( $interactive ) = shift;
   if (!defined $interactive) {
      $interactive = 0;
   }
   &show_progversion;
   if (! $interactive) {
      print "\n" .
            "Usage:\n" .
            "   perl4w32 dbf2csv.pl file.dbf ...\n" .
            "or (under MS-DOS):\n" .
            "   perl4s dbf2csv.pl file.dbf ...\n" .
            "or (if you have a 32-bit Perl installed):\n" .
            "   perl dbf2csv.pl file.dbf ...\n" .
            "or (to run interactively under Windows and prompt for the .dbf file):\n" .
            "   perl4w dbf2csv.pl -p\n" .
            "\n" .
            "For each input file.dbf, an output file.csv will be created.\n" .
            "There will be one more record in file.csv than file.dbf, because the\n" .
            "field names are written to file.csv as the first record.\n" .
            "A dot will printed for every 2000 records, as a progress indicator.\n" .
            "\n" .
            "Options:  (e.g., \"perl4w32 dbf2csv.pl -d infile.dbf\".)\n" .
            "   -j    to output a JSON (.json) file instead of CSV (experimental!)\n" .
            "   -d    to enable debug prints\n" .
            "   -p    special intaractive mode for use with perl4w.exe\n" .
            "   -ta   to translate DOS PC-style accented characters to ANSI\n" .
            "   -tu   to translate DOS PC-style accented characters to unaccented\n" .
            "   -e0   translate CR, LF etc. to blanks (this is default for CSV)\n" .
            "   -e1   translate CR, LF etc. to \\r \\n etc. (this is default for JSON)\n" .
            "   -e2   like -e0 except double \"-marks (for CSV only)\n" .
            "\n" .
            "Limitations:  dBase (.DBT) Memo fields are unsupported, though FoxPro (.FPT)\n" .
            "Memo fields work.  Also, dBase 7 files are completely unsupported.\n" .
            "Also, if you use a 16-bit version of Perl, such as perl4s\n" .
            "or perl4w, then you must use \"8.3\" (short) file names, and '-j' (JSON)\n" .
            "mode creates .JSO files (instead of .json).\n";
   } else {
      # interactive mode
      print "\n" .
            "For each .dbf input file that you specify, an output file will be\n" .
            "created with the same name but a .csv extension.\n" .
            "\n" .
            "For big files, a dot will printed for every 2000 records, as a\n" .
            "progress indicator.  There is no limit on the size of the files,\n" .
            "but big files may take a long time to convert.\n" .
            "\n" .
            "There will be one more record in the .csv output file than in the .dbf\n" .
            "file, because the field names are written to the .csv file as the\n" .
            "first record.\n" .
            "\n" .
            "Options (you may enter an option instead of a file name):\n" .
            "   -j  to output a JSON (.json) file instead of CSV (experimental!)\n" .
            "   -d  to enable debug prints\n" .
            "   -ta  to translate DOS-style accented characters to ANSI\n" .
            "   -tu  to translate DOS-style accented characters to unaccented\n" .
            "   -e0  translate CR, LF etc. to blanks (this is default for CSV)\n" .
            "   -e1  translate CR, LF etc. to \\r \\n etc. (this is default for JSON)\n" .
            "   -e2  like -e0 except double \"-marks (for CSV only)\n" .
            "\n" .
            "Note that you might have to specify the full path of each .dbf file.\n";
   }
} #do_help


# From the Perl documentation, it isn't clear whether the 'v' and 'V' template
# characters do signed or unsigned conversions.  I thought it was signed, but
# it seems to be unsigned.  This tests it, and prints the result.  This is only
# called when the user specifieds the "-d" (debug) command-line parameter.
sub tst_vV {
   local($tst_v_fmt, $tst2, $tst_V_fmt);

   if ($perl_supports_IEEE754_doubles) {
      print "This Perl supports IEEE-754 double-precision numbers.\n";
   } else {
      print "This Perl does NOT support IEEE-754 double-precision numbers.\n";
   }

   $tst_v_fmt = "\xFF\xFF\xFF\xFF";
   $tst2 = unpack("v",$tst_v_fmt);
   if (-1 == $tst2) {
      print "'v' format is signed.\n";
   } elsif (65535 == $tst2) {
      print "'v' format is unsigned.\n";
   } else {
      print "ERROR: 'v' format is mishandled!!  0xFFFF -> $tst2\n";
   }

   $tst_V_fmt = "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF";
   $tst2 = unpack("V",$tst_V_fmt);
   if (-1 == $tst2) {
      print "'V' format is signed.\n";
   } elsif (4294967295 == $tst2) {
      print "'V' format is unsigned.\n";
   } else {
      print "'V' format is unsigned!  0xFFFFFFFF -> $tst2\n";
   }
}


sub process_a_file_or_option {
   local( $inFile ) = shift;
   if ("-d" eq $inFile) {
      $debugmode = 1;
      print "TLIB revision no. $ver_ordinal_and_date\n";
      &tst_vV;
   } elsif ("-d0" eq $inFile) {
      $debugmode = 0;
   } elsif ("-p" eq $inFile) {
      # Special interactive mode for use with Perl4w.exe
      $prompt = 1;
   } elsif ("-j" eq $inFile) {
      # JSON mode (instead of CSV)
      $jsonmode = 1;
   } elsif ("-j0" eq $inFile) {
      $jsonmode = 0;
   } elsif ("-ta" eq $inFile) {
      # translate DOS PC-style accented characters to to ANSI-style accented characters
      $translate = 1;
      $garde_accent = 1;
   } elsif ("-tu" eq $inFile) {
      # translate DOS PC-style accented characters to to unaccented characters
      $translate = 1;
      $garde_accent = 0;
   } elsif (("-e" eq $inFile) || ("-e1" eq $inFile)) {
      $escape_codes = 1;
   } elsif ("-e2" eq $inFile) {
      $escape_codes = 2;
   } elsif ("-e0" eq $inFile) {
      $escape_codes = 0;
   } elsif ("-tn" eq $inFile) {
      # no translations
      $translate = 0;
   } elsif (("-?" eq $inFile) || ("-h" eq $inFile) || ("--help" eq $inFile)) {
      &do_help;
   } else {
      &do_a_file( $inFile );
   }
} #process_a_file_or_option


# Main program
# Test if there are parameters
if (($#ARGV+1) < 1) {  # no, show help
   &do_help;
   exit 1;
} else {
   while ($#ARGV >= 0) {
      $inFile = $ARGV[0];
      shift @ARGV;
      &process_a_file_or_option( $inFile );
   } #while

   # default is backslash-escape sequences for JSON, or dumb/simple for CSV
   if (-1 == $escape_codes) {
      $escape_codes = $jsonmode;
   }

   if ($prompt) {
      &do_help( 1 );  # interactive version of help message
      do {
         print "\n";
         if ($debugmode) {
            print "[debugmode enabled]\n";
         }
         print "Convert what .DBF file?  (or press Enter alone to quit) ";
         $inFile = <STDIN>;
         # remove leading and trailing whitespace (especially the CR at the end)
         $inFile =~ s/\s*(\S((.*\S)|)|)\s*/$1/;
         if ('' ne $inFile) {
            &process_a_file_or_option( $inFile );
         }
      } until ('' eq $inFile);
   }

   if (! $prompt) {
      exit $errlevel;
   }
   # An idiosyncracy of Perl4w.exe is that if you exit by dropping off
   # the end of the program it closes the Window, but if you exit by
   # calling 'exit' or 'die' then it leaves the window open.  Since we
   # want the window to close, we don't call 'exit'.
}

__END__

