<?php
    require 'vendor/autoload.php';
    use \Michelf\Markdown;
    # Read file and pass content through the Markdown parser
    $text = file_get_contents('README.md');
    $html = Markdown::defaultTransform($text);

?>
<!DOCTYPE html>
<html>
    <head>
        <title>MiRacLe's SlackBuilds</title>
    </head>
    <body>
	<?php
	    # Put HTML content in the document
	    echo $html;
	?>
    </body>
</html>