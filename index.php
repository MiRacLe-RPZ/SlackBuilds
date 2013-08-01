<?php
    require 'vendor/autoload.php';
    use \Michelf\Markdown;

    if ('POST' == $_SERVER['REQUEST_METHOD']) {
        $is_github = function() {
             $ip = ip2long($_SERVER['REMOTE_ADDR']);
             foreach (array('204.232.175.64/27','192.30.252.0/22') as $cidr) {
                 list($subnet, $mask) = explode('/', $cidr);
                 if (($ip & ~((1 << (32 - $mask)) - 1) ) == ip2long($subnet)) { 
                    return true;
                 }
             }
             return false;
        };
        if ($is_github()) {
            fastcgi_finish_request();
            chdir(__DIR__);
            `git pull > /dev/null 2>&1 &`;
            exit;
        }
    } else {
        $text = file_get_contents('README.md');
        $html = Markdown::defaultTransform($text);
?>
<!DOCTYPE html>
<html>
    <head>
        <title>MiRacLe's SlackBuilds</title>
        <style type="text/css">
         body {background-color: #eee;}
        </style>
    </head>
    <body>
    <?php
        # Put HTML content in the document
        echo $html;
    ?>
    </body>
</html>
<?php
    }
?>
