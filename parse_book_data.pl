######################################################################################
# Program Name: parse_book_data.pl
# Description:  Reads a pipe-delimited text file containing book data
#               a splits it into the table specific files.
#               Key IDs are calculated as the data is parsed.
# Created:	    July 25, 2016
# Programmer:   Thomas Leppert
######################################################################################
#------------------------------Declare Pragma----------------------------
use strict;		                               # Enforce strict syntax
#use DBI;		                               # Database access
#use DBD::ODBC;                                 # DBI data type for ODBC
use File::Copy;                                # File move and copy
use FileHandle;                                # Object file handle

# General program vars
my $ProgName   = 'parse_book_data';
my $DIEPROC    = \&complete_report;              # Die call clean up procedure
my $zipcmd     = 'C:/"Program Files/"7-Zip/7z';  # Command to run Zip
my $Message;                                     # Sub-procedure errors
my $LogDate;                                     # Beginning and ending time for log file
my $LogExt     = FileDateStamp();                # Log file date and time stamp

# Directory information
my $ProjDir = 'C:/Users/Tom/MyProjects';         # Project work tree
my $LogDir  = join ('/', $ProjDir, 'Log');       # Log file directory
my $DatDir  = join('/', $ProjDir, 'Data');       # Extract file direcotry

# File information
my $LogH;                                        # Log file handle
# Log file
my $LogFile = join('/', $LogDir, join('.', join('_', $ProgName, $LogExt), 'log'));
my $InFileH;                                     # Input file handle
my $InFile  = join('/', $DatDir,'export.csv' );  # Input file
my $OutFileH;                                    # Output file handle
my $OutFile;                                     # Data file
my $LineCount = 0;                               # Data file line count
my $FieldReq  = 14;                              # Number of fields needed

# Arrays for Data
my @Book;                                        # Books fact
my %Author;                                      # Author fact
my @BookAuthor;                                  # Book-Author fact
my @BookSeries;                                  # Book-Series fact
my @BookComment;                                 # Book comments fact
my @BookLoan;                                    # Book loan fact
my %SeriesDefn;                                  # Series dim
my %PublisherDefn;                               # Publisher dim
my %TypeDefn;                                    # Book format dim
my %CategoryDefn;                                # Category dim
my %SubCatDefn;                                  # Sub-Category dim
my %StatusDefn;                                  # Read status dim

# Initailize keys we need to calculate.  Only BOOK has them in the data
my $SeriesId    = 1;                             # Series_Defn
my $PublisherId = 1;                             # Publisher_Defn
my $TypeId      = 1;                             # Type_Defn
my $CategoryId  = 1;                             # Category_Defn
my $SubCatId    = 1;                             # Sub_Category_Defn
my $StatusId    = 1;                             # Status_Defn
my $RatingId    = 0;                             # Rating_Defn always None
my $AuthorId    = 1;                             # Author

# Define some working objects so we don't keep making new ones
# as we process the records.
my $FieldCount;                                  # Count of fields in a line
my @RecData     = ();                            # Working array
my $BookKey;                                     # Book_ID
my $SeriesKey;                                   # Series_ID
my $PublisherKey;                                # Publisher_ID
my $TypeKey;                                     # Type_ID
my $CategoryKey;                                 # Category_ID
my $SubCatKey;                                   # Sub_Category_ID
my $StatusKey;                                   # Status_ID
my $AuthorKey;                                   # Author_ID
my $Delim       = '|';                           # Record delimiter
my $SDelim      = '\|';                          # Need to escape the pipe or
                                                 # split doesn't behave
######################################################################################
### BEGIN PROGRAM
######################################################################################
# Open Log file.  Log all errors and messages
$Message = FileOpenClose(\$LogH, $LogFile, 'WRITE');

if ($Message) {
   die "$Message";
}

WriteLog($LogH, "BEGIN: $ProgName\n");

# Open the data file for read.
$Message = FileOpenClose(\$InFileH, $InFile, 'READ');

if ($Message) {
	DieLog($LogH, $Message);
}

# Read the records in the data file and load the database arrays
# Remember the first record is the column headings to skip it if this is record 1
foreach my $record (<$InFileH>) {
	# Clear working values to prevent values from jumping records
	@RecData = ();
	undef $BookKey;
	undef $PublisherKey;
	undef $TypeKey;
	undef $CategoryKey;
	undef $SubCatKey;
	undef $StatusKey;
	undef $AuthorKey;
	
	# Get rid of new line
	chomp($record);
	
	# Skip first line 
	next if ($LineCount == 0);
	
	# Check the count of delimeters. If it isn't the correct number, skip the record
	$FieldCount  = ($record =~ tr/$Delim//);
	if ($FieldCount != $FieldReq) {
		WriteLog($LogH, "ERROR: Incorrect number of fields on line $LineCount : $FieldCount");
		WriteLong($LogH, "INFO: $record");
		next;
	}
	# Split the file record into a working array. Need to use the escaped version since pipe is regex indicator
	# Record layout is:
	# Field[0]: Count
	# Field[1]: Book #
	# Field[2]: Series
	# Field[3]: Series#
	# Field[4]: Title
	# Field[5]: Author
	# Field[6]: Book Type
	# Field[7]: Category
	# Field[8]: Sub-Category
	# Field[9]: Publisher
	# Field[10]: Published
	# Field[11]: ISBN/ASIN
	# Field[12]: Read?
	# Field[13]: On Loan To:
	# Field[14]: Notes
	@RecData = split(/$SDelim/, $record);
	
	# Clean up the data to get avoid potential problems
	foreach (@RecData) {
        s/\t/ /;  # Convert TAB to space. Do first in case it is at the end or beginning.
        s/^\s+//; # Delete any leading spaces
        s/\s+$//; # Delete any leading or trailing spaces
    }
	
	# Start setting the vaules for the Book record.  This will require the Defn hashes to be 
	# updated and read.  Author will be handled as it's own loop since that data will need to
	# be split as well.
	$BookKey = $RecData[2];
	
	# IF the book is in a series, then look up the series id for it and add it to the
	# the @BookSeries fact
	
	# If the book doesn't have a type, then default to Unknown ($PublisherKey = 0).
	# Otherwise look up the type's id
	
	# If the book doesn't have a category, then default to Unknown ($TypeKey = 0)
	# Otherwise look  up the category's id
	
	# If the book doesn't have a sub-category, then default it to None ($SubCatKey = 0)
	# Otherwise look up the sub-category's id
	
	# If the book doesn't have a publisher, then default it to Unknown ($PublisherKey = 0)
	# Otherwise look up the publisher's id
	
	# If the book doesn't have a status, then default it to Unknown ($StatusKey = 0)
	# Otherwise look up the status's id

	# Build the complete BOOK record and add it to the @Book fact data
	
	# If the book has author's defined, process them.  Authors are a semi-colon delimited
	# list of names
	
	
	# Update the count of lines
	$LineCount++;
}


complete_report($Message);

#######################################################################################
### FUNCTION SECTIONS
#######################################################################################
#--------------------------------------------------------------------------------------
# lookup_dim: Lookup ID key for a dimension value.  If the value
#             has not been assigned an ID, then calculate the next
#             available ID and add it to the list.
#    INPUT: 
#         $logf    - Log file handle
#         $dimref  - Reference to the dimension hash that has
#                    assigned ID numbers
#         $nextkey - Reference to next available key to assign
#                    for the dimension.
#         $invalue - Dimension value to look up
#    OUTPUT:
#         $id      - ID for the dimension value 
#--------------------------------------------------------------------------------------
sub lookup_dim {
	my $logf    = shift;
	my $dimref  = shift;
	my $nextkey = shift;
	my $invalue  = shift;
	
	my $id;
	
	if ( exists($$dimref{$invalue} ) ) {
	    $id = $$dimref{$invalue};
	    WriteLog($logf, "lookup_dim: INFO: Found $invalue\n");
	} else {
		WriteLog($logf, "lookup_dim: INFO:$invalue not found\n");
		#$dimref->{$invalue} = $$nextkey;
		$$dimref{$invalue} = $$nextkey;    # Add to assigned IDS
		$id = $$nextkey;
		$$nextkey++;		               # Update next available ID
	}
    WriteLog($logf,  "lookup_dim: INFO:Return $id\n");
    return($id);
}
#--------------------------------------------------------------------------------------
# DieLog: Log program failures and trigger a die call.
#         $DIEPROC - Name of procedure to call when dieing.
#                    Allows additional clean up processing to
#                    occur. This is assumed to be a global var
#                    Declared as: \&subprocedure_name
#    INPUT: 
#         $logf    - Log file handle
#         $msg     - Message to write
#    OUTPUT:
#         NONE
#--------------------------------------------------------------------------------------
sub DieLog {
 my $logf    = shift;
 my $msg     = shift;

 $msg=join("FATAL:", $msg);

 WriteLog($logf, "$msg");

 if ($DIEPROC) {
     &$DIEPROC($msg);
 } else {
     die "$msg";
 }

}
 
#--------------------------------------------------------------------------------------
# WriteLog: Write an entry to the log file.
#           Takes a file handle and message.
#    INPUT:
#         $logf  - Log file handle
#         $msg   - Message to write
#   OUTPUT:
#          NONE
#--------------------------------------------------------------------------------------
sub WriteLog {
 my $logf= shift;
 my $msg = shift;

 my $logdate = LogDate();

 print $logf "[$logdate] $msg";
# print "[$logdate] $msg";
}

#--------------------------------------------------------------------------------------
# LogDate: Get the date and time.  The procedure can return a 
#           date and/or time based on the $date_type parameter
#    INPUT:
#          $date_type - type of date and time to return
#                       D     => YYYY/MM/DD
#                       T     => HH24:MI:SS
#                       I     => YYYY-MM-DDTHH24:MI:SS (ISO 8601)
#                       undef => YYYY/MM/DD HH24:MI:SS
#   OUTPUT:
#          $datetime  - current date and time
#--------------------------------------------------------------------------------------
sub LogDate {
 my $date_type = shift;

 my $datetime;

# Force uppercase
 $date_type = uc($date_type);

 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

 if ($date_type eq 'D') {
### Date Only
    $datetime = sprintf("%04d/%02d/%02d", (1900+$year), (1+$mon), $mday);
 } elsif ($date_type eq 'T') {
### Time Only
    $datetime = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
 } elsif ($date_type eq 'I') {
### ISO 8601 format (no timezone)
    $datetime=sprintf("%04d-%02d-%02dT%02d:%02d:%02d", (1900+$year), (1+$mon), 
                        $mday, $hour, $min, $sec);
 } else {
###Default date and time.
    $datetime = sprintf("%04d/%02d/%02d %02d:%02d:%02d", (1900+$year), (1+$mon), 
                        $mday, $hour, $min, $sec);
 }
 return($datetime);
}

#--------------------------------------------------------------------------------------
# FileDateStamp: Return date, time or date-time stamp.
#    INPUT: 
#          $exttype - Type of file extension
#                     D     => YYYYMMDD
#                     T     => HH24MI
#                     undef => YYYYMMDDHH24MI
#   OUTPUT: 
#          $retval  - Date and time in specified format
#--------------------------------------------------------------------------------------
sub FileDateStamp {
   my $exttype = shift;

   my $retval;

# Force uppercase
   $exttype = uc($exttype);

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

   if ($exttype eq 'D') {
# Date only
      $retval = sprintf("%04d%02d%02d", (1900+$year), (1+$mon), $mday);
   } elsif ($exttype eq 'T') {
# Time only
      $retval = sprintf("%02d%02d",  $hour, $min);

   } else {
# Date and time.
      $retval = sprintf("%04d%02d%02d%02d%02d", (1900+$year), (1+$mon), $mday, $hour, $min);
   }
    return($retval);
}

#--------------------------------------------------------------------------------------
# FileOpenClose: Open or close a file for read, write or append.
#                Check action.
#                If the action if valid:
#                +For open options, check if the file handle already has a value.  
#                   +If it does, then error out that the handle is already in use. 
#                   +If the file handle isn't in use, then try and open the file.  
#                      +If it succeeds, then unbuffer the output with autoflush so 
#                       that entries appear in the file as soon as they are written.  
#                      +If the open fails, pass back the error.  
#                +If the handle is to be closed, then check if the handle has a value.
#                  +If it doesn't then error out, the handle is not active.
#                    +If it has a value, then close the handle.
#                      +If the close succeeds, undef the file handle so that 
#                       that entries appear it can be used for testing if a file 
#                       is open.
#                    +If the close fails, pass back the error.
#               If acton is invalid return an error
#    INPUT:
#          $fh_ref   - Reference to file handle to create
#          $filename - File name to open or close
#          $action   - Action to perform on file:
#                      WRITE, APPEND, READ, CLOSE      
#   OUTPUT:
#          $retmsg   - Error if action failed or undef
#                      if it succeeded.
#--------------------------------------------------------------------------------------
sub FileOpenClose {
  my $fh_ref   = shift;
  my $filename = shift;
  my $action   = shift;

  my $retmsg;



  if ($action =~/WRITE/i) {
     if (defined $$fh_ref) {
        $retmsg="FileOpenClose: ERROR: Filehandle already in use\n";
     } else {
       if ($$fh_ref= new FileHandle ">$filename") {
          $$fh_ref->autoflush;
       } else {
          $retmsg="FileOpenClose: ERROR: Couldn't Open $filename for write: $!\n";
       }
     }
  } elsif ($action=~/APPEND/i) {
     if (defined $$fh_ref) {
        $retmsg="FileOpenClose: ERROR: Filehandle already in use\n";
     } else {
       if ($$fh_ref= new FileHandle ">>$filename") {
          $$fh_ref->autoflush;
       } else {
          $retmsg="FileOpenClose: ERROR: Couldn't Open $filename for append: $!\n";
       }
     }
  } elsif ($action=~/READ/i) {
     if (defined $$fh_ref) {
        $retmsg="FileOpenClose: ERROR: Filehandle already in use\n";
     } else {
       unless ($$fh_ref= new FileHandle "$filename") {
          $retmsg="FileOpenClose: ERROR: Couldn't Open $filename for read: $!\n";
       }
     }
  } elsif ($action=~/CLOSE/i) {
     if (defined $$fh_ref) {
        if ($$fh_ref->close) {
            undef $$fh_ref;
        } else {
          $retmsg="FileOpenClose: ERROR: Couldn't Close $filename: $!\n";
        }
      } else {
        $retmsg="FileOpenClose: ERROR: Filehandle not active.\n";
      }
  } else {
    $retmsg="FileOpenClose: ERROR: Invalid Action: $action for file $filename\n";
  }
  return($retmsg);
}

#--------------------------------------------------------------------------------------
# FileCopyMove: Move file to interface directory to be picked up by
#               the load program.
#    INPUT:
#         $logf       - Log file handle
#         $sourcefile - Source file name
#         $targetfile - Destination file name
#         $action     - Action to take
#                       C => Copy file from source to target
#                       M => Move file from source to target
#   OUTPUT:
#         $retmsg     - Error message if failed
#--------------------------------------------------------------------------------------
sub FileCopyMove {
  my $logf       = shift;
  my $sourcefile = shift;
  my $targetfile = shift;
  my $action     = shift;

  my $retmsg;

  WriteLog($logf, "BEGIN: FileCopyMove\n");

# Force action to uppercase
  $action = uc($action);

  if ($action eq 'C') {
# Copy file
     if ( copy($sourcefile, $targetfile) ) {
         WriteLog($logf, "FileCopyMove: INFO: Copy $sourcefile to $targetfile Successful\n");
     } else {
         $retmsg="FileCopyMove: IERROR: Copy of $sourcefile to $targetfile failed Code: $!\n";
         WriteLog($logf, "$retmsg");
     }
  } elsif ($action eq 'M') {
# Move file
     if ( move($sourcefile, $targetfile) ) {
         WriteLog($logf, "FileCopyMove: IINFO: Move $sourcefile to $targetfile Successful\n");
     } else {
         $retmsg="FileCopyMove: IERROR: Move of $sourcefile to $targetfile failed Code: $!\n";
         WriteLog($logf, "$retmsg");
     }
  } else {
# Bad value
     $retmsg="Invalid action $action.";
     WriteLog($logf, "FileCopyMove: ERROR: $retmsg");
  }

  WriteLog($logf, "END: FileCopyMove\n");

  return($retmsg);
}

#--------------------------------------------------------------------------------------
# CheckFileExist: Check if a file exists.
#    INPUT:
#         $filename - Filename with directory to search for
#   OUTPUT:
#         1 - Exists
#         0 - Not Exist
#--------------------------------------------------------------------------------------
sub CheckFileExist {
  my $filename = shift;

  if (-e "$filename") {
     return(1);
  } else {
     return(0);
  }
}

#--------------------------------------------------------------------------------------
# complete_report: Disconnect from data base, mail and backup
#                  log file.
#   INPUT:
#        $diemsg - Fatal error message (if any)
#   OUTPUT:
#         NONE
#--------------------------------------------------------------------------------------
sub complete_report {
 my $diemsg  = shift;

 my $retmsg;              # Error message from calls
 my $retcode;             # System error codes

# Step 2: Close log file
 WriteLog($LogH, "END: $ProgName\n");

 $retcode = FileOpenClose(\$LogH, $LogFile, 'CLOSE');
 if ($retcode) {
    $diemsg = join(' ', $diemsg, "complete_report: ERROR: FATAL: Unable to close $LogFile: $retcode\n");
 }


 if ($diemsg) {
    die "$diemsg\n";
 } else {
   exit;
 }
}