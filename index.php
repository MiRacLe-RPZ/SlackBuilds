<?php
    require 'vendor/autoload.php';
    use Michelf\Markdown;

    if ('POST' == $_SERVER['REQUEST_METHOD']) {
        fastcgi_finish_request();
        if (false !== ($lock = fopen(__DIR__ . DIRECTORY_SEPARATOR .'.lock','w+'))) {
            if (flock($lock,LOCK_EX)) {
                $is_github = static function() {
                    $ip = ip2long($_SERVER['REMOTE_ADDR']);
                    foreach (array('192.30.252.0/22','185.199.108.0/22','140.82.112.0/20') as $cidr) { // https://api.github.com/meta
                        list($subnet, $mask) = explode('/', $cidr);
                        if (($ip & ~((1 << (32 - $mask)) - 1) ) === ip2long($subnet)) {
                            return true;
                        }
                    }
                    return false;
                };
                if ($is_github()) {
                    chdir(__DIR__);
                    `git pull > /dev/null 2>&1 &`;
                }
                flock($lock,LOCK_UN);
            }
            fclose($lock);
        }
    } else {
        $text = file_get_contents('README.md');
        $readme = Markdown::defaultTransform($text);
        $files = glob('*/*.info');
        $packages = array();
        foreach ($files as $file) {
            $info = parse_ini_file($file);
            $packages[] = $info;
        }
?>
<!DOCTYPE html>
<html>
    <head>
        <title>MiRacLe's SlackBuilds</title>
        <style type="text/css">
         body {background-color: #eee;}
         span.pkgnam {font-weight: bold;}
         span.version {color: gray;}
         a.home { background-image: url('//icons.iconarchive.com/icons/artua/mac/16/Home-icon.png'); background-position: 0 0; background-repeat: no-repeat; color: transparent; width: 20px; display: inline-block; }
        </style>
    </head>
    <body>
    <?php
        # Put HTML content in the document
        echo $readme;
    ?>
    <div id="packages">
    <h3>Available packages</h3>
     <ul>
       <?php
          foreach ($packages as $pkg) {
              echo sprintf('<li><a class="home" href="%s">homepage</a><span class="pkgnam">%s</span> <span class="version">%s</span></li>',$pkg['HOMEPAGE'], isset($pkg['PKGNAM']) ? $pkg['PKGNAM'] : $pkg['PRGNAM'] ,$pkg['VERSION']);
          }
       ?>
     </ul>
    </div>
    </body>
</html>
<?php
    }
?>
