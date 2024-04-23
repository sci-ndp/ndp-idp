<!DOCTYPE html>
<html>
    <head>
        <title>${msg("accountManagementTitle")}</title>

        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="robots" content="noindex, nofollow">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <script>
            <#if properties.developmentMode?has_content && properties.developmentMode == "true">
            var developmentMode = true;
            var reactRuntime = 'react.development.js';
            var reactDOMRuntime = 'react-dom.development.js';
            var reactRouterRuntime = 'react-router-dom.js';
            <#else>
            var developmentMode = false;
            var reactRuntime = 'react.production.min.js';
            var reactDOMRuntime = 'react-dom.production.min.js';
            var reactRouterRuntime = 'react-router-dom.min.js';
            </#if>
            var authUrl = '${authUrl}';
            var baseUrl = '${baseUrl}';
            var realm = '${realm.name}';
            var resourceUrl = '${resourceUrl}';
            var isReactLoading = false;

            <#if properties.logo?has_content>
            var brandImg = resourceUrl + '${properties.logo}';
            <#else>
            var brandImg = resourceUrl + '/public/logo.svg';
            </#if>

            <#if properties.logoUrl?has_content>
            var brandUrl = '${properties.logoUrl}';
            <#else>
            var brandUrl = logoUrl;
            </#if>

            var features = {
                isRegistrationEmailAsUsername : ${realm.registrationEmailAsUsername?c},
                isEditUserNameAllowed : ${realm.editUsernameAllowed?c},
                isInternationalizationEnabled : ${realm.isInternationalizationEnabled()?c},
                isLinkedAccountsEnabled : ${realm.identityFederationEnabled?c},
                isMyResourcesEnabled : ${(realm.userManagedAccessAllowed && isAuthorizationEnabled)?c},
                deleteAccountAllowed : ${deleteAccountAllowed?c},
                updateEmailFeatureEnabled: ${updateEmailFeatureEnabled?c},
                updateEmailActionEnabled: ${updateEmailActionEnabled?c},
                isViewGroupsEnabled : ${isViewGroupsEnabled?c}
            }

            var availableLocales = [];
            <#list supportedLocales as locale, label>
                availableLocales.push({locale : '${locale}', label : '${label}'});
            </#list>

            <#if referrer??>
                var referrer = '${referrer}';
                var referrerName = '${referrerName}';
                var referrerUri = '${referrer_uri}'.replace('&amp;', '&');
            </#if>

            <#if msg??>
                var locale = '${locale}';
                <#outputformat "JavaScript">
                var l18nMsg = JSON.parse('${msgJSON?js_string}');
                </#outputformat>
            <#else>
                var locale = 'en';
                var l18Msg = {};
            </#if>
        </script>

        <#if properties.favIcon?has_content>
        <link rel="icon" href="${resourceUrl}${properties.favIcon}" type="image/x-icon"/>
        <#else>
        <link rel="icon" href="${resourceUrl}/public/favicon.ico" type="image/x-icon"/>
        </#if>

        <script src="${authUrl}js/keycloak.js"></script>

        <#if properties.developmentMode?has_content && properties.developmentMode == "true">
        <!-- Don't use this in production: -->
        <script src="${resourceUrl}/node_modules/react/umd/react.development.js" crossorigin></script>
        <script src="${resourceUrl}/node_modules/react-dom/umd/react-dom.development.js" crossorigin></script>
        <script src="https://unpkg.com/babel-standalone@6.26.0/babel.min.js"></script>
        </#if>

        <#if properties.extensions?has_content>
            <#list properties.extensions?split(' ') as script>
                <#if properties.developmentMode?has_content && properties.developmentMode == "true">
        <script type="text/babel" src="${resourceUrl}/${script}"></script>
                <#else>
        <script type="text/javascript" src="${resourceUrl}/${script}"></script>
                </#if>
            </#list>
        </#if>

        <#if properties.scripts?has_content>
            <#list properties.scripts?split(' ') as script>
        <script type="text/javascript" src="${resourceUrl}/${script}"></script>
            </#list>
        </#if>

        <script>
            var content = <#include "resources/content.json"/>
        </script>

        <link rel="stylesheet" href="${resourceCommonUrl}/node_modules/@patternfly/react-core/dist/styles/base.css"/>
        <link rel="stylesheet" href="${resourceCommonUrl}/node_modules/@patternfly/patternfly/patternfly-addons.css"/>
        <link rel="stylesheet" href="${resourceUrl}/public/app.css"/>
        <link rel="stylesheet" href="${resourceUrl}/public/layout.css"/>

        <#if properties.styles?has_content>
            <#list properties.styles?split(' ') as style>
            <link href="${resourceUrl}/${style}" rel="stylesheet"/>
            </#list>
        </#if>
    </head>

    <body>

        <script>
            var keycloak = new Keycloak({
                authServerUrl: authUrl,
                realm: realm,
                clientId: 'account-console'
            });
            keycloak.init({onLoad: 'check-sso'}).then((authenticated) => {
                isReactLoading = true;
                toggleReact();
                if (!keycloak.authenticated) {
                    document.getElementById("landingSignInButton").style.display='inline';
                    document.getElementById("landingSignInLink").style.display='inline';
                } else {
                    document.getElementById("landingSignOutButton").style.display='inline';
                    document.getElementById("landingSignOutLink").style.display='inline';
                    document.getElementById("landingLoggedInUser").innerHTML = loggedInUserName('${msg("unknownUser")}', '${msg("fullName")}');
                }

                loadjs("/Main.js");
            }).catch(() => {
                alert('failed to initialize keycloak');
            });
        </script>

<div id="main_react_container" style="display:none;height:100%"></div>

<div id="spinner_screen" role="progressbar" style="display:block; height:100%">
    <div style="width: 320px; height: 328px; text-align: center; position: absolute; top:0;	bottom: 0; left: 0;	right: 0; margin: auto;">
        <div class="brand-logo">
            <img src="${resourceUrl}/img/ndp_logo.png" alt="NDP Logo">
            <img src="${resourceUrl}/img/nsf-logo.png" alt="NSF Logo">
        </div>

        <p>${msg("loadingMessage")}</p>
        <div>
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="margin: auto; background: rgb(255, 255, 255); display: block; shape-rendering: auto;" width="200px" height="200px" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid">
                <path d="M10 50A40 40 0 0 0 90 50A40 42 0 0 1 10 50" fill="#5DBCD2" stroke="none" transform="rotate(16.3145 50 51)">
                    <animateTransform attributeName="transform" type="rotate" dur="1s" repeatCount="indefinite" keyTimes="0;1" values="0 50 51;360 50 51"></animateTransform>
                </path>
            </svg>
        </div>
    </div>
</div>

<div id="welcomeScreen" style="display:none;height:100%">
    <div class="pf-c-page" id="page-layout-default-nav">
      <header role="banner" class="pf-c-page__header">
        <div class="pf-c-page__header-brand">
            <div class="brand-logo">
                <a href="https://nationaldataplatform.org" target="_blank"><img src="${resourceUrl}/img/ndp_logo.png" alt="NDP Logo"></a>
                <a href="https://www.nsf.gov/" target="_blank"><img src="${resourceUrl}/img/nsf-logo.png" alt="NSF Logo"></a>
            </div>
        </div>
        <div class="pf-c-page__header-tools">
            <#if referrer?has_content && referrer_uri?has_content>
            <div class="pf-c-page__header-tools-group pf-m-icons pf-u-display-none pf-u-display-flex-on-md">
              <a id="landingReferrerLink" href="${referrer_uri}" class="pf-c-button pf-m-link" tabindex="0">
                  <span class="pf-c-button__icon pf-m-start">
                      <i class="pf-icon pf-icon-arrow" aria-hidden="true"></i>
                  </span>
                  ${msg("backTo",referrerName)}
              </a>
            </div>
            </#if>

            <div class="pf-c-page__header-tools-group pf-m-icons pf-u-display-none pf-u-display-flex-on-md pf-u-mr-md">
              <button id="landingSignInButton" tabindex="0" style="display:none" onclick="keycloak.login();" class="pf-c-button pf-m-primary" type="button">${msg("doSignIn")}</button>
              <button id="landingSignOutButton" tabindex="0" style="display:none" onclick="keycloak.logout();" class="pf-c-button pf-m-primary" type="button">${msg("doSignOut")}</button>
            </div>

            <!-- Kebab for mobile -->
            <div class="pf-c-page__header-tools-group pf-u-display-none-on-md">
                <div id="landingMobileKebab" class="pf-c-dropdown pf-m-mobile" onclick="toggleMobileDropdown();"> <!-- pf-m-expanded -->
                    <button aria-label="Actions" tabindex="0" id="landingMobileKebabButton" class="pf-c-dropdown__toggle pf-m-plain" type="button" aria-expanded="true" aria-haspopup="true">
                        <svg fill="currentColor" height="1em" width="1em" viewBox="0 0 192 512" aria-hidden="true" role="img" style="vertical-align: -0.125em;"><path d="M96 184c39.8 0 72 32.2 72 72s-32.2 72-72 72-72-32.2-72-72 32.2-72 72-72zM24 80c0 39.8 32.2 72 72 72s72-32.2 72-72S135.8 8 96 8 24 40.2 24 80zm0 352c0 39.8 32.2 72 72 72s72-32.2 72-72-32.2-72-72-72-72 32.2-72 72z" transform=""></path></svg>
                    </button>
                    <ul id="landingMobileDropdown" aria-labelledby="landingMobileKebabButton" class="pf-c-dropdown__menu pf-m-align-right" role="menu" style="display:none">
                        <#if referrer?has_content && referrer_uri?has_content>
                        <li role="none">
                            <a id="landingMobileReferrerLink" href="${referrer_uri}" role="menuitem" tabindex="0" aria-disabled="false" class="pf-c-dropdown__menu-item">${msg("backTo",referrerName)}</a>
                        </li>
                        </#if>

                        <li id="landingSignInLink" role="none" style="display:none">
                            <a onclick="keycloak.login();" role="menuitem" tabindex="0" aria-disabled="false" class="pf-c-dropdown__menu-item">${msg("doLogIn")}</a>
                        </li>
                        <li id="landingSignOutLink" role="none" style="display:none">
                            <a onclick="keycloak.logout();" role="menuitem" tabindex="0" aria-disabled="false" class="pf-c-dropdown__menu-item">${msg("doSignOut")}</a>
                        </li>
                    </ul>
                </div>
            </div>

            <span id="landingLoggedInUser"></span>

        </div> <!-- end header tools -->
      </header>

      <main role="main" class="pf-c-page__main">
        <section class="pf-c-page__main-section pf-m-limit-width pf-m-light pf-m-shadow-bottom">
            <div class="pf-c-page__main-body">
                <div class="pf-c-content" id="landingWelcomeMessage">
                    <h1>${msg("accountManagementWelcomeMessage")}</h1>
                </div>
            </div>
        </section>
        <section class="pf-c-page__main-section pf-m-limit-width pf-m-overflow-scroll">
            <div class="pf-c-page__main-body">
                <div class="pf-l-gallery pf-m-gutter">
                    <#assign content=theme.apply("content.json")?eval>
                    <#list content as item>
                        <div class="pf-l-gallery__item" id="landing-${item.id}">
                            <div class="pf-c-card pf-m-full-height">
                                <div>
                                    <div class="pf-c-card__title pf-c-content">
                                        <h2 class="pf-u-display-flex pf-u-w-100 pf-u-flex-direction-column">
                                            <#if item.icon??>
                                                <i class="pf-icon ${item.icon}"></i>
                                            <#elseif item.iconSvg??>
                                                <img src="${item.iconSvg}" alt="icon"/>
                                            </#if>
                                            ${msg(item.label)}
                                        </h2>
                                    </div>
                                    <div class="pf-c-card__body">
                                        <#if item.descriptionLabel??>
                                            <p class="pf-u-mb-md">${msg(item.descriptionLabel)}</p>
                                        </#if>
                                        <#if item.content??>
                                            <#list item.content as sub>
                                                <div id="landing-${sub.id}">
                                                    <a onclick="toggleReact(); window.location.hash='${sub.path}'">${msg(sub.label)}</a>
                                                </div>
                                            </#list>
                                        <#else>
                                            <a id="landing-${item.id}" onclick="toggleReact(); window.location.hash = '${item.path}'">${msg(item.label)}</a>
                                        </#if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </#list>
                </div>
            </div>
        </section>
      </main>
    </div>
</div>
<footer class="ndp-footer">
    <div class="footer-content">
        <div class="footer-logo">
            <!-- The NSF logo could be placed here as an image or as a background in CSS -->
        </div>
        <div class="footer-logo2">
            <!-- The NSF logo could be placed here as an image or as a background in CSS -->
        </div>
        <div class="footer-text">
            <p>Contact - ndp@sdsc.edu</p>
            <p>The National Data Platform was funded by NSF 2335609 under CI, CISE Research Resources programs. Any opinions, findings, conclusions, or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the funders.</p>
        </div>
        <div class="footer-social">
            <div class="css-nwfosv">
                <a target="_blank" rel="noopener" class="chakra-link css-1seouga social-icon" href="https://www.instagram.com/nationaldataplatform">
                    <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 448 512" height="25" width="25" xmlns="http://www.w3.org/2000/svg">
                        <path d="M224.1 141c-63.6 0-114.9 51.3-114.9 114.9s51.3 114.9 114.9 114.9S339 319.5 339 255.9 287.7 141 224.1 141zm0 189.6c-41.1 0-74.7-33.5-74.7-74.7s33.5-74.7 74.7-74.7 74.7 33.5 74.7 74.7-33.6 74.7-74.7 74.7zm146.4-194.3c0 14.9-12 26.8-26.8 26.8-14.9 0-26.8-12-26.8-26.8s12-26.8 26.8-26.8 26.8 12 26.8 26.8zm76.1 27.2c-1.7-35.9-9.9-67.7-36.2-93.9-26.2-26.2-58-34.4-93.9-36.2-37-2.1-147.9-2.1-184.9 0-35.8 1.7-67.6 9.9-93.9 36.1s-34.4 58-36.2 93.9c-2.1 37-2.1 147.9 0 184.9 1.7 35.9 9.9 67.7 36.2 93.9s58 34.4 93.9 36.2c37 2.1 147.9 2.1 184.9 0 35.9-1.7 67.7-9.9 93.9-36.2 26.2-26.2 34.4-58 36.2-93.9 2.1-37 2.1-147.8 0-184.8zM398.8 388c-7.8 19.6-22.9 34.7-42.6 42.6-29.5 11.7-99.5 9-132.1 9s-102.7 2.6-132.1-9c-19.6-7.8-34.7-22.9-42.6-42.6-11.7-29.5-9-99.5-9-132.1s-2.6-102.7 9-132.1c7.8-19.6 22.9-34.7 42.6-42.6 29.5-11.7 99.5-9 132.1-9s102.7-2.6 132.1 9c19.6 7.8 34.7 22.9 42.6 42.6 11.7 29.5 9 99.5 9 132.1s2.7 102.7-9 132.1z">
                        </path>
                    </svg>
                </a>
                <a target="_blank" rel="noopener" class="chakra-link css-1seouga social-icon" href="https://twitter.com/natldataplat">
                    <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 512 512" height="25" width="25" xmlns="http://www.w3.org/2000/svg">
                        <path d="M389.2 48h70.6L305.6 224.2 487 464H345L233.7 318.6 106.5 464H35.8L200.7 275.5 26.8 48H172.4L272.9 180.9 389.2 48zM364.4 421.8h39.1L151.1 88h-42L364.4 421.8z">
                        </path>
                    </svg>
                </a>
                <a target="_blank" rel="noopener" class="chakra-link css-1seouga social-icon" href="https://www.linkedin.com/company/national-data-platform">
                    <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 448 512" height="25" width="25" xmlns="http://www.w3.org/2000/svg">
                        <path d="M416 32H31.9C14.3 32 0 46.5 0 64.3v383.4C0 465.5 14.3 480 31.9 480H416c17.6 0 32-14.5 32-32.3V64.3c0-17.8-14.4-32.3-32-32.3zM135.4 416H69V202.2h66.5V416zm-33.2-243c-21.3 0-38.5-17.3-38.5-38.5S80.9 96 102.2 96c21.2 0 38.5 17.3 38.5 38.5 0 21.3-17.2 38.5-38.5 38.5zm282.1 243h-66.4V312c0-24.8-.5-56.7-34.5-56.7-34.6 0-39.9 27-39.9 54.9V416h-66.4V202.2h63.7v29.2h.9c8.9-16.8 30.6-34.5 62.9-34.5 67.2 0 79.7 44.3 79.7 101.9V416z">
                        </path>
                    </svg>
                </a>
            </div>
        </div>
    </div>
</footer>
    <script>
      const removeHidden = (content) => {
        content.forEach(c => {
          if (c.hidden && eval(c.hidden)) {
            document.getElementById('landing-' + c.id).remove();
          }
          if (c.content) removeHidden(c.content);
        });
      }
      removeHidden(content);
    </script>

    </body>
</html>
