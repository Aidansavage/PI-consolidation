use strict;
use warnings;
use JSON::XS;
use Data::Dumper;
use LWP::UserAgent;

#use Net::SSL;
use URI::Escape;

use diagnostics;

####
#### Tk module use block
use Tk;
use Tk::LabFrame;
use Tk::NoteBook;
use Tk::BrowseEntry;
use Tk::DialogBox;
####
our $coderef = "checking for spam";
print $main::coderef;
our $main = MainWindow->new;
$main->geometry("800x600");

#our $authcode = $main->Label()              ->grid( -row => 5, -column => 1, -columnspan => 10 );

$main->configure( -menu => my $menubar = $main->Menu );
my $file    = $menubar->cascade( -label => '~File' );
my $edit    = $menubar->cascade( -label => '~Edit' );
my $help    = $menubar->cascade( -label => '~Help' );
my $service = $menubar->cascade( -label => '~Service' );

### put stuff in File menu
$file->separator;
$file->command(
    -label       => "Quit",
    -accelerator => 'Ctrl-q',
    -underline   => 0,
    -command     => \&exit,
);

### put stuff in Edit menu
$edit->command( -label => 'Preferences ...' );

### put stuff in Help menu
$help->command( -label => 'Version', -command => sub { print "Version\n" } );
$help->separator;
$help->command( -label => 'About', -command => sub { print "About\n" } );

### put stuff in Service menu
$service->command(
    -label       => "Open Server",
    -accelerator => 'Ctrl-o',
    -underline   => 0,
    -command     => \&Server,
);

our $URLmutable = "https://esi.tech.is/latest/";
our $URL = $main->Label()->grid( -row => 1, -column => 1, -columnspan => 10 );
$URL->configure( -text => "${URLmutable}" );
my $endpoint = 'Search';

my $frame          = $main->Frame;
my $endpointchoice = $frame->BrowseEntry(
    -label    => "Endpoint:",
    -variable => \$endpoint,
    ,
    -browsecmd => \&EndpointSelected
);
$endpointchoice->pack;
&BuildEndpoint;
my $buttonframe = $frame->Frame;
$buttonframe->Button(
    -text    => "Print value",
    -command => sub {
        print "The endpoint is $endpoint\n";
    },
    -relief => "raised"
)->pack;

$buttonframe->pack;
$frame->grid( -row => 2, -column => 1 );
my $operation;
our $operationchoice;
my $frame2 = $main->Frame;
$operationchoice = $frame2->BrowseEntry(
    -label     => "Search Type:",
    -variable  => \$operation,
    -browsecmd => \&OperationPop

);

=begin comment
    -listcmd  => sub {
        if ( $endpoint eq 'Search' ) {
            $operationchoice->configure(
                                     -choices => [
                                                   'agent',     'alliance',
                                                   'character', 'constellation',
                                                   'corporation',   'faction',
                                                   'inventorytype', 'region',
                                                   'solarsystem',   'station',
                                                   'wormhole'
                                     ]
            );
        }
        else { 1 }
    }
=end comment
=cut

$operationchoice->pack;

my $buttonframe2 = $frame2->Frame;
$buttonframe2->Button(
    -text    => "Print value",
    -command => sub {
        print "The operation type is $operation\n";
    },
    -relief => "raised"
)->pack;

$buttonframe2->pack;
$frame2->grid( -row => 2, -column => 2 );

MainLoop;

sub BuildEndpoint {
    $endpointchoice->configure(
        -choices => [
            'alliances', 'characters', 'corporations', 'dogma',
            'search',    'industry',   'insurance',    'markets',
            'universe',
        ]
    );
}

sub EndpointSelected {

    #access subroutine arguments via $_[index] to grab selection choice
    my $arg = $_[1];
    print "\n\n";
    print $arg;
    if ( $arg eq 'alliances' ) {
        my $temp = $URL->cget( -text );

    }
    elsif ( $arg eq 'search' ) {
        my $temp = $URL->cget( -text );
        print "\n\nCurrent URL is $temp\n";

        #$temp=
        $URL->configure( -text => "${temp}${arg}/?categories=" );
        print "\n\nNew built URL is " . $URL->cget( -text );
        $operationchoice->configure(
            -choices => [
                'agent',         'alliance',
                'character',     'constellation',
                'corporation',   'faction',
                'inventorytype', 'region',
                'solarsystem',   'station',
                'wormhole'
            ]
        );
    }
    else { 1 }
}

#the following sub contains the lwp useragent building stuff, use when necessary
sub useragentstuff {

    # Create a user agent object
    our $hostname = "https://esi.tech.ccp.is/latest/";
    print "current iteration is _latest \n";
    print "please select an endpoint (test with search): \t";
    our $endpoint = <stdin>;
    chomp($endpoint);
    print "\nplease select a category if applicable (test with region): \t";
    our $categories = <stdin>;
    chomp($categories);
    print "\nplease select a region to search for:\t";
    our $search = <stdin>;
    chomp($search);
    print "\nsanitizing unsafe characters\n";
    our $urlsanity = uri_escape($search);

    our $URL =
"${hostname}${endpoint}/?categories=${categories}&datasource=tranquility&language=en-us&search=${urlsanity}&strict=false";
    print "\n\n$URL\n\n";

    #our $sanitizedURL = uri_escape($URL);
    #print "\n\n$sanitizedURL\n\n";
    our $json;

    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1 ");

    # Create a request
    my $req = HTTP::Request->new( GET => $URL );
    $req->content_type('application/json');

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    # Check the outcome of the response
    if ( $res->is_success ) {
        print $res->content;
        print "\nparsing response\n";
        $json = $res->decoded_content;
        print Dumper($json);
    }
    else {
        print $res->status_line, "\n";
    }

    our %test        = %{ decode_json($json) };
    our @anothertest = @{ $test{'region'} };

    print @anothertest;
    print $anothertest[0];

}

#  10000002 the forge

# 34 tritanium

=begin comment
sub Auth {

 use Tk::DialogBox;
    our $pid;
    $main::box = $main::main->DialogBox(-title => "Authorization", -buttons => ["OK"],
			-command=> sub {
			kill('KILL', $pid);
			},
			);
    my $widget = $main::box->add('Label', -text=> "Click OK when Authorization is complete")->pack;
    
 
$main::coderef = undef;


{
 package MyWebServer;
 
 use HTTP::Server::Simple::CGI;
 use base qw(HTTP::Server::Simple::CGI);
  use Data::Dumper;
 my %dispatch = (
     '/hello' => \&resp_hello,
	 '/callback' => \&resp_code,
     # ...
 );
 
 sub handle_request {
     my $self = shift;
     my $cgi  = shift;
   
     our $path = $cgi->path_info();
	
     my $handler = $dispatch{$path};

     if (ref($handler) eq "CODE") {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
       #  print $cgi->param('code');
     } else {
         print "HTTP/1.0 404 Not found\r\n";
         print $cgi->header,
		 print $cgi->path_info();
               $cgi->start_html('Not found'),
               $cgi->h1('Not found'),
               $cgi->end_html;
     }
 }
 
 sub resp_hello {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;
     
     my $who = $cgi->param('name');
     my $what = $cgi->param('code');
     print $cgi->header,
           $cgi->start_html("Hello"),
           $cgi->h1("Hello $who!"),
		   $cgi->h2("\nYour code is $what");
           $cgi->end_html;
 }
 
  sub resp_code {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;
     
     my $what = $cgi->param('code');
     
     print $cgi->header,
           $cgi->start_html("Hello"),
           $cgi->h1("Code is $what"),
           $cgi->end_html;
$main::coderef = $what;
 $main::authcode = $main::main->Label()->grid(-row=>5, -column=>1, -columnspan=>10);
$main::authcode->configure(-textvariable=>\$main::coderef);
 }

 } 

 


$pid = MyWebServer->new(8080)->background();
print "Use 'kill $pid' to stop server.\n";
use WWW::Shorten::TinyURL;

my $shorturl= makeashorterlink('https://login.eveonline.com/oauth/authorize?response_type=code&redirect_uri=http://localhost:8080/callback&client_id=a530913af26a4316a94c24a9a15d3bbc&state=12345');
my @command = ('start', $shorturl);
async{system(@command)};

  my $button = $main::box->Show;

 }
=end comment

=cut

sub Server {
    my $servertop = $main->Toplevel(
        -title  => 'Auth Server',
        -width  => '100',
        -height => '100',
    );
    $main::status = "Server Not Running";
    my $serverstatus = $servertop->Label( -textvariable => \$main::status, )
      ->grid( -row => 1, -columnspan => 2, -column => 1 );
    $main::pid = undef;
    my $start = $servertop->Button(
        -text    => "Start Server",
        -width   => 30,
        -command => sub {
            $main::status = "Starting Server";
            &ServerStart;
        },
    )->grid( -row => 2, -columnspan => 2, -column => 1 );

    my $authenticate = $servertop->Button(
        -text    => "Authenticate",
        -width   => 14,
        -command => sub {
            $main::status = "Authenticating";
            use WWW::Shorten::TinyURL;

            my $shorturl = makeashorterlink(
'https://login.eveonline.com/oauth/authorize?response_type=code&redirect_uri=http://localhost:8080/callback&client_id=a530913af26a4316a94c24a9a15d3bbc&state=12345'
            );
            my @command = ( 'start', $shorturl );
            system(@command);
        },
    )->grid( -row => 3, -column => 1 );

    my $tokenfetch = $servertop->Button(
        -text    => "Fetch Token",
        -width   => 14,
        -command => \&Fetchtoken,
    )->grid( -row => 3, -column => 2 );

    my $stop = $servertop->Button(
        -text    => "Stop Server",
        -width   => 30,
        -command => sub {
            $main::status = "Closing Server";
            $servertop->update;
            kill( 'KILL', $main::pid ), sleep 10;
            $main::status = "Server Not Running";
        },
    )->grid( -row => 4, -columnspan => 2, -column => 1 );

    1;
}

sub ServerStart {

    # $main::coderef = undef;

    {

        package MyWebServer;

        use HTTP::Server::Simple::CGI;
        use base qw(HTTP::Server::Simple::CGI);
        use Data::Dumper;
        our %dispatch = (
            '/hello'    => \&resp_hello,
            '/callback' => \&resp_code,

            # ...
        );

        sub handle_request {
            my $self = shift;
            my $cgi  = shift;

            our $path = $cgi->path_info();

            my $handler = $dispatch{$path};

            if ( ref($handler) eq "CODE" ) {
                print "HTTP/1.0 200 OK\r\n";
                $handler->($cgi);

                #  print $cgi->param('code');
            }
            else {
                print "HTTP/1.0 404 Not found\r\n";
                print $cgi->header, print $cgi->path_info();
                $cgi->start_html('Not found'),
                  $cgi->h1('Not found'),
                  $cgi->end_html;
            }
        }

        sub resp_hello {
            my $cgi = shift;    # CGI.pm object
            return if !ref $cgi;

            my $who  = $cgi->param('name');
            my $what = $cgi->param('code');
            print $cgi->header,
              $cgi->start_html("Hello"),
              $cgi->h1("Hello $who!"),
              $cgi->h2("\nYour code is $what");
            $cgi->end_html;
        }

        sub resp_code {
            my $cgi = shift;    # CGI.pm object
            return if !ref $cgi;

            my $what = $cgi->param('code');

            print $cgi->header,
              $cgi->start_html("Hello"),
              $cgi->h1("Code is $what"),
              $cgi->end_html;
            $MyWebServer::authcode = "$what";
            print
              "authorization code is stored in \$MyWebServer::authcode, and is "
              . $MyWebServer::authcode;
            open( my $fh, '>', 'authcode.txt' );
            print $fh $MyWebServer::authcode;
            close $fh;
            $main::authcode = $main::main->Label()
              ->grid( -row => 5, -column => 1, -columnspan => 10 );
            $main::authcode->configure(
                -textvariable => \$MyWebServer::authcode );
        }
        print "authorization code is stored in \$MyWebServer::authcode, and is "
          . $MyWebServer::authcode;

    }

    package main;
    $main::pid = MyWebServer->new(8080)->background();
    print "Use 'kill ", $main::pid, "' to stop server.\n";
    $main::status = "Server running: " . $main::pid;
}

sub Fetchtoken {
    open( my $fh, '<', 'authcode.txt' );

    my $authed = <$fh>;
    chomp $authed;
    print "\n" . $authed . "\tauthentication code\n";

    #print Dumper($coderef);
    use LWP::UserAgent;
    use MIME::Base64;

    my $ua = LWP::UserAgent->new;
    $ua->agent("Indy Helper/0.1 ");
    my $encoded = encode_base64(
"a530913af26a4316a94c24a9a15d3bbc:JxAMpaFJg7WBtPrIyhXmqEVARrCeyrFenHnzk8Nn"
    );
    my $json = "{'grant_type':'authorization_code','code':'" . $authed . "'}";

    # Create a request
    my $req =
      HTTP::Request->new( POST => 'https://login.eveonline.com/oauth/token' );
    $req->content_type('application/json');
    $ua->default_header( 'Authorization' => "Basic " . $encoded );

    #$ua->default_header("grant_type" => "authorization_code");
    #$ua->default_header("code" => "$authed");
    #$ua->default_header("content_size" =>70);
    $req->content($json);

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    # Check the outcome of the response
    if ( $res->is_success ) {
        print $res->content;
    }
    else {
        print $res->status_line, "\n";
    }
}

