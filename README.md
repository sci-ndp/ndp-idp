# Base Keycloak Docker Deployment Guide

This guide provides a comprehensive overview for deploying a Keycloak Authentication and Authorization (AAI) project using Docker Compose. It includes steps for obtaining SSL certificates through Let's Encrypt.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
  - [Certbot Installation](#1-certbot-installation-for-ssl)
  - [SSL Certificate Generation](#2-ssl-certificate-generation)
  - [Configuring the Project](#3-configuring-the-project)
  - [Launching Docker Compose](#4-launching-docker-compose)
- [Important Directories](#important-directories)
- [Additional Considerations](#additional-considerations)
  - [Production Deployment](#production-deployment)
  - [REALM Configuration](#realm-configuration)
  - [Email Configuration](#email-configuration)
    - [Setting Up App Password for Gmail](#Setting-up-app-password-for-gmail)
    - [SSL problems](#ssl-problems)
    - [Adding an Identity Provider (IdP)](#adding-an-identity-provider-(idp))
    - [Creating a Client](#creating-a-client)


## Prerequisites

- Docker and Docker Compose installed on your host machine.
- For SSL configurations: A registered domain name pointing to your host machine's IP address.

## Deployment Steps

### 1. Certbot Installation (for SSL)

Certbot is a tool for obtaining and installing free SSL certificates from Let's Encrypt. Install it using one of the following commands:

```bash
sudo yum install certbot
# or
sudo pip install certbot
```

### 2. SSL Certificate Generation

Generate and set up your SSL certificates:

```bash
openssl req -newkey rsa:2048 -nodes -keyout server.key.pem -x509 -days 3650 -out server.crt.pem
chmod 755 server.key.pem
# Move the generated certificates to `SSL/certificates`
```

### 3. Configuring the Project

Configure three main services: the API, the PostgreSQL database, and the Keycloak instance.

- **API**: Ensure values in `aai_api/app.py` match those in the `.env` file and that the `API_PORT` value is correctly defined.
- **PostgreSQL**: Configure user, password, database, data storage, and service details in the `.env` file.
- **Keycloak**: Adjust settings based on deployment requirements:
  - `KEYCLOAK_THEMES`: Place compatible themes with the used Keycloak version in `aai_config/themes` for custom styling. For faciltiating the process we added themes for the 24.0.1 Keycloak version that have compliant NDP styles of the current NDP UI.
  - `KEYCLOAK_REALM_JSON`: If you don't have one, you will need to change the configuration to not use a realm (delete `KEYCLOAK_IMPORT` and `--import-realm`) and once you create the Keycloak insatnce download your own. For faciltiating the process we added a NDP realm at `aai_config/realm.json` as needed. Adjust passwords manually if they reset during import.

The other configuration values of the `.env` file are easier to configure, just make sure that they correctly reference the Postgres service for persisting the Keycloak data.

Finally, ensure that the `HOSTNAME` variable is correctly set to your DNS value.

### 4. Launching Docker Compose

Deploy your project with Docker Compose:

```bash
docker-compose up -d
```

## Important Directories

- **SSL**: Contains `certificates` needed for SSL, named as specified in the `.env` file.
- **aai_data**: Default directory to store the full database. Avoid altering or deleting this without backup. Do not push to your Git repository.
- **aai_config**: Includes the base NDP realm (`realm.json`) and a `themes` directory with custom NDP styles.
- **aai_api**: Includes the `Dockerfile` and simple API for getting Keycloak data insights.

## Additional Considerations

### Production Deployment

For production, adjust nginx configurations and remove the `start-dev` command from the Docker Compose file. Ensure SSL setup is complete and `.env` values are correct.

### REALM Configuration

For REALM changes or backups:
  1. Access the admin console at `https://<your_domain>:<your_port>/admin/master/console/`.
  2. Navigate to `Realm settings`, select `Action`, and perform a `partial export`. Replace passwords that reset to `*****` with their actual values.

 If you experience issues importing the `realm.json` file, look for `"type": "js"` within the file. Remove the entire content of the `"policies": []` arrays associated with `"type": "js"`, resulting in `"policies": []`.

### Email Configuration

Enable verified email functionality in `Realm settings -> Login -> Verify email`. 

Configure email to allow Keycloak to send emails:
1. Go to `Realm settings -> Email`.
2. Fill the `Template` with the desired mail configuration.
    - From: The email address that will appear in the "From" field of the emails sent by Keycloak, which should be the same as the Username.
    - Envelope From (Optional): Use it if you need to specify a different return-path for the emails.
3. Fill the `Connection & Authentication`, for gmail this are working values:
    - Host: ``smtp.gmail.com``
    - Port: Use ``465`` for SSL encryption or ``587`` for STARTTLS encryption.
    - Authentication: ``Enabled``:
        - ``Username``: Your full Gmail email address.
        - ``Password``: You will need to generate an App password from your Google account's security settings.

#### Setting Up App Password for Gmail

Detailed guide: https://support.google.com/mail/answer/18583

1. Activate Two-Factor Authentication (2FA) on the Gmail account under the Security tab.
2. Go to the bottom of the Verification in two steps and generate an App Password.
3. It should be something like this: `fcmm pgah ymrc ftsl`. So copy and put it in the `Password` field of the Kyecloak `Connection & Authentication` section part

#### Good Practice: Do the same in the `master` REALM

### SSL problems

- If the `certbot` command isn't recognized, try using the full path, such as `/usr/local/bin/certbot`.
- The Docker Compose configuration assumes that the SSL certificates are located in the `SSL/certificates` directory. If your certificates are in a different location, ensure you update the paths in the Docker Compose and nginx configuration files.
- Let's Encrypt certificates must be renewed every 90 days. You can automate this process by configuring a cron job to execute `certbot renew`.

### Adding an Identity Provider (IdP)

Identity Providers (IdPs) enable users to log in to your Keycloak-protected applications using their credentials from external sources like Google, Facebook, or corporate identity services supporting OpenID Connect or SAML.

1. Navigate to Keycloak Admin Console: Access the Keycloak Admin Console, and go to the Identity Providers section in the side menu.
2. Choose an Identity Provider: For most use cases, the OpenID Connect v1.0 protocol is recommended.
3. Configure the IdP: Provide essential details such as Alias (a name to identify this IdP configuration), Client ID, and Client Secret (credentials obtained from the IdP you are integrating with). The configuration varies based on the chosen IdP but typically includes URLs for authorization, token, and user info endpoints.
4. Client Authentication: While there are several ways to authenticate your client with the IdP, using the Client secret sent as basic auth is one of the simplest and most secure methods. It sends the client ID and secret in the Authorization header when making requests to the IdP.


### Creating a Client

Clients in Keycloak represent applications that can request authentication and authorization. They can be anything from a web app, a backend API, or a mobile app.

1. Access the Keycloak Admin Console: Navigate to the Clients section from the side menu.
2. Click `Create Client` and enter a unique Client ID and Name. Also as client type choose openid-connect for modern applications.
3. Client authentication:
    - OFF: Public, for client-side applications where the client secret cannot be securely stored.
    - ON: Confidential, for applications that can securely store client secrets. This type requires a secret to initiate the login process and is the recomended
4. Authorization: When enabled, Keycloak acts as a policy decision point to grant or deny access based on these policies, roles, and the configuration of scopes. When disabled, the client does not use Keycloak's built-in authorization capabilities, and any access control must be implemented at the application level.
5. Authentication flow: The important ones are:
    - Standard Flow: Recommended for most web applications. It's a redirect flow where Keycloak handles authentication and redirects back to the app with tokens.
    - Direct Access Grants: Suitable for applications that can securely handle a user's credentials to directly exchange them for tokens with Keycloak.
    - Implicit Flow: Less secure, mostly used by clients that cannot securely store secrets. Not recommended for new applications.


Then, once its created:
- Root URL: The URL where your FastAPI service is accessible, e.g., https://api.yourdomain.com.
- Valid Redirect URIs: Set to specific URIs where your service might redirect after authentication, e.g., https://yourdomain.com/*. Can use wildcards like `*` or `+`.
