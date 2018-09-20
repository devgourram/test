#!/bin/bash
echo "Debut du build"
echo "Copie du parameters.yml"
rm -rf /var/lib/jenkins/jobs/IadEspanaApp/workspace/vendor/*

cp app/config/parameters.yml.build app/config/parameters.yml
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Composer update"
rm -rf composer.lock
rm -rf vendor
/usr/sbin/composer -v install --no-interaction
if [ "$?" != "0" ]; then
    exit 1;
fi
php bin/console cache:clear --env=test
echo "Creation de la base de données"
php bin/console doctrine:database:drop --force --env=test
php bin/console doctrine:database:create --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Mise à jour du schema doctrine"
php bin/console doctrine:schema:update  --force --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Doctrine validation"
php bin/console doctrine:schema:validate --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
# echo "Chargement des fixtures"
# php bin/console hautelook_alice:doctrine:fixtures:load --append --env=test --no-interaction -b IadDbBundle -b IadDirectoryDbBundle -b IadRealEstateBundle -b MyIadBundle -b IadAppBundle -b IadCapacitationBundle -b IadGenealogyBundle -b IadTransactionBundle -b AbsenceManagementBundle  -b IadGatewayBundle
# php bin/console iad:geocode:migrate 1000 --env=test
echo "Lancement des tests phpunit"
php bin/console cache:clear --env=test
phpunit
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Suprresion de la base de données"
php bin/console doctrine:database:drop --force --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "PHPCS Symfony3"
phpcs  /var/lib/jenkins/jobs/IadEspanaApp/workspace/src -n --colors --ignore=Tests --error-severity=1 --standard=vendor/Symfony3-custom-coding-standard/Symfony3Custom
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Security check"
php bin/console security:check --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "Lint YAML"
php bin/console lint:yaml app/config --env=test
if [ "$?" != "0" ]; then
    exit 1;
fi
rm bin/config/parameters.yml
if [ "$?" != "0" ]; then
    exit 1;
fi
echo "build passed"
echo "Fin du build"
exit 0;
