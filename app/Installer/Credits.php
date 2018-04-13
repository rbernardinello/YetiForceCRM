<?php

namespace App\Installer;

/**
 * Get info about libraries.
 *
 * @copyright YetiForce Sp. z o.o
 * @license   YetiForce Public License 3.0 (licenses/LicenseEN.txt or yetiforce.com)
 * @author    Adrian Koń <a.kon@yetiforce.com>
 */
class Credits
{
	/**
	 * Library json files.
	 *
	 * @var string[]
	 */
	public static $jsonFiles = ['package.json', 'composer.json', 'bower.json'];
	/**
	 * Information about libraries license.
	 *
	 * @var array
	 */
	public static $licenses = [
		'ckeditor/ckeditor' => 'MPL-1.1+',
		'block-ui' => 'MIT',
		'dompurify' => 'Apache-2.0',
		'html5shiv' => 'MIT',
		'jquery-slimscroll' => 'MIT',
		'optimist' => 'MIT',
		'updated-jqplot' => 'MIT',
		'color-convert' => 'MIT',
		'humanize' => 'MIT',
		'microplugin' => 'Apache-2.0',
		'@fortawesome/fontawesome-free-regular' => 'MIT',
		'@fortawesome/fontawesome-free-solid' => 'MIT',
	];
	/**
	 * Information about forks CRM.
	 *
	 * @var array
	 */
	public static $libraries = ['Vtiger' => ['name' => 'Vtiger', 'version' => '6.4.0 rev. 14548', 'license' => 'VPL 1.1', 'homepage' => 'https://www.vtiger.com/', 'notPackageFile' => true], 'Sugar' => ['name' => 'Sugar CRM', 'version' => '', 'license' => 'SPL-1.1.2', 'homepage' => 'https://www.sugarcrm.com/', 'notPackageFile' => true]];

	/**
	 * Function gets libraries from vendor.
	 *
	 * @throws \App\Exceptions\AppException
	 *
	 * @return array
	 */
	public static function getVendorLibraries()
	{
		$libraries = [];
		if (file_exists(ROOT_DIRECTORY . '/composer.lock')) {
			$composerLock = \App\Json::decode(file_get_contents(ROOT_DIRECTORY . '/composer.lock'), true);
			if ($composerLock && $composerLock['packages']) {
				foreach ($composerLock['packages'] as $package) {
					$libraryDir = ROOT_DIRECTORY . DIRECTORY_SEPARATOR . 'vendor' . DIRECTORY_SEPARATOR;
					$libraries[$package['name']] = self::getLibraryValues($package['name'], $libraryDir);
					if (!empty($package['version'])) {
						$libraries[$package['name']]['version'] = $package['version'];
					}
					if ($package['license'] && count($package['license']) > 1) {
						$libraries[$package['name']]['license'] = implode(', ', $package['license']);
						$libraries[$package['name']]['licenseError'] = true;
					} else {
						$libraries[$package['name']]['license'] = $package['license'][0];
					}
					if (isset(static::$licenses[$package['name']])) {
						$libraries[$package['name']]['license'] = static::$licenses[$package['name']] . ' [' . $libraries[$package['name']]['license'] . ']';
						$libraries[$package['name']]['licenseError'] = false;
					}
					if (!empty($package['homepage'])) {
						$libraries[$package['name']]['homepage'] = $package['homepage'] ?? 'https://packagist.org/packages/' . $package['name'];
					} elseif (empty($libraries[$package['name']]['homepage'])) {
						$libraries[$package['name']]['homepage'] = 'https://packagist.org/packages/' . $package['name'];
					}
				}
			}
		}
		return $libraries;
	}

	/**
	 * Function gets libraries name from public_html.
	 *
	 * @throws \App\Exceptions\AppException
	 *
	 * @return array
	 */
	public static function getPublicLibraries()
	{
		$libraries = [];
		$dir = ROOT_DIRECTORY . DIRECTORY_SEPARATOR . 'public_html' . DIRECTORY_SEPARATOR . 'libraries' . DIRECTORY_SEPARATOR;
		if (file_exists($dir . '.yarn-integrity')) {
			$yarnFile = \App\Json::decode(file_get_contents($dir . '.yarn-integrity'), true);
			if ($yarnFile && $yarnFile['lockfileEntries']) {
				$libraryDir = ROOT_DIRECTORY . DIRECTORY_SEPARATOR . 'public_html' . DIRECTORY_SEPARATOR . 'libraries' . DIRECTORY_SEPARATOR;
				foreach ($yarnFile['lockfileEntries'] as $nameWithVersion => $page) {
					$isPrefix = strpos($nameWithVersion, '@') === 0;
					$name = $isPrefix ? '@' : '';
					$name .= array_shift(explode('@', $isPrefix ? ltrim($nameWithVersion, '@') : $nameWithVersion));
					$libraries[$name] = self::getLibraryValues($name, $libraryDir);
				}
			}
		}
		return $libraries;
	}

	/**
	 * Function return library values.
	 *
	 * @param string $name
	 * @param string $dir
	 *
	 * @throws \App\Exceptions\AppException
	 *
	 * @return array
	 */
	public static function getLibraryValues($name, $dir)
	{
		$library = ['name' => $name, 'version' => '', 'license' => '', 'homepage' => ''];
		$existJsonFiles = true;
		foreach (self::$jsonFiles as $file) {
			$packageFile = $dir . $name . DIRECTORY_SEPARATOR . $file;
			if (file_exists($packageFile)) {
				$existJsonFiles = false;
				$packageFileContent = \App\Json::decode(file_get_contents($packageFile), true);
				if (!empty($packageFileContent['version']) && empty($library['version'])) {
					$library['version'] = $packageFileContent['version'];
				}
				if (!empty($packageFileContent['homepage']) && empty($library['homepage'])) {
					$library['homepage'] = $packageFileContent['homepage'];
				}
			}
		}
		$license = self::getLicenseInformation($dir, $name);
		if (!empty($license['license'])) {
			$library['licenseError'] = $license['error'];
			$library['license'] = $license['license'];
			$library['licenseToDisplay'] = $license['licenseToDisplay'];
		}
		if ($existJsonFiles) {
			$library['packageFileMissing'] = true;
		}
		return $library;
	}

	/**
	 * Function return license information for library.
	 *
	 * @param string $dir
	 * @param string $libraryName
	 *
	 * @return array
	 */
	public static function getLicenseInformation($dir, $libraryName)
	{
		$licenseError = false;
		$returnLicense = '';
		$licenseToDisplay = '';
		foreach (self::$jsonFiles as $file) {
			$packageFile = $dir . $libraryName . DIRECTORY_SEPARATOR . $file;
			if (file_exists($packageFile)) {
				$packageFileContent = \App\Json::decode(file_get_contents($packageFile), true);
				$license = $packageFileContent['license'] ?? $packageFileContent['licenses'];
				if ($license) {
					if (is_array($license)) {
						if (is_array($license[0]) && isset($license[0]['type'])) {
							$returnLicense = implode(', ', array_column($license, 'type'));
						} else {
							$returnLicense = implode(', ', $license);
						}
						if (count($license) > 1) {
							$licenseError = true;
						}
					} else {
						$licenseError = self::validateLicenseName($license);
						$returnLicense = $license;
					}
					if (isset(static::$licenses[$libraryName]) && $returnLicense) {
						$returnLicense = static::$licenses[$libraryName] . " [$returnLicense]";
						$licenseToDisplay = static::$licenses[$libraryName];
						$licenseError = false;
						break;
					} elseif ($returnLicense) {
						break;
					}
				}
			}
		}
		return ['license' => $returnLicense, 'error' => $licenseError, 'licenseToDisplay' => $licenseToDisplay];
	}

	/**
	 * Function check correct of license.
	 *
	 * @param array|string $license
	 *
	 * @return bool
	 */
	public static function validateLicenseName($license)
	{
		if (!$license) {
			return true;
		}
		$result = false;
		if (!is_array($license)) {
			$license = [$license];
		}
		foreach ($license as $value) {
			if (stripos($value, 'and') || stripos($value, ' or ') || $value === null) {
				$result = true;
			}
		}
		return $result;
	}

	/**
	 * Function returns information abouts libraries.
	 *
	 * @throws \App\Exceptions\AppException
	 *
	 * @return array
	 */
	public static function getCredits()
	{
		return ['static' => static::$libraries, 'vendor' => self::getVendorLibraries(), 'public' => self::getPublicLibraries()];
	}
}
