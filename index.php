<?php
    require 'vendor/autoload.php';
    use \Michelf\Markdown;
    
    if ('POST' == $_SERVER['REQUEST_METHOD']) {
        $is_github = function() {
             foreach (array('204.232.175.64/27','192.30.252.0/22') as $cidr) {
                 list($subnet, $mask) = explode('/', $cidr);
                 if ((ip2long($ip) & ~((1 << (32 - $mask)) - 1) ) == ip2long($subnet)) { 
                    return true;
                 }
             }
             return false;
        };
        if ($is_github()) {
            $payload = json_decode($_REQUEST['payload']);
            chdir(__DIR__);
            fastcgi_finish_request();_
            `git pull > /dev/null 2>&1 &`;
            exit;
        }
    } else {
        $text = file_get_contents('README.md');
        $html = Markdown::defaultTransform($text);
    }
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