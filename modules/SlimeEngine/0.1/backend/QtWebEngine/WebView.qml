/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtWebEngine 1.1
import "../base"
import "../../CertificateError.js" as CertificateError
import "../../LoadStatus.js" as LoadStatus
import "../../NewViewRequest.js" as NewViewRequest
import "../../Feature.js" as Feature
import "../../MessageLevel.js" as MessageLevel


Holding {
    core: webview

    onReadyChanged: {
        if (ready)
            webview.finishCreation();
    }

    WebEngineView {
        id: webview
        anchors.fill: parent
        zoomFactor: pipe.zoomFactor

        profile: pipe.profile.backend.backendInstance.core

        property string backendName: "QtWebEngine"

        onLoadingChanged: {
            var status;
            switch(loadRequest.status) {
                case WebEngineView.LoadStartedStatus:
                    status = LoadStatus.LoadStarted;
                    break;
                case WebEngineView.LoadStoppedStatus:
                    status = LoadStatus.LoadStopped;
                    break;
                case WebEngineView.LoadSucceededStatus:
                    status = LoadStatus.LoadSucceeded;
                    break;
                case WebEngineView.LoadFailedStatus:
                    status = LoadStatus.LoadFailed;
                    break;
            }
            pipe.loadingChanged(Events.getLoadingChangedEvent(loadRequest.url, status, loadRequest.errorCode != 0, loadRequest.errorCode, loadRequest.errorString));
        }

        onFullScreenRequested: {
            pipe.fullScreenRequested(Requests.getFullScreenRequest(webview, request.toggleOn, request));
        }

        onNewViewRequested: {
            var destination;
            switch (request.destination) {
                case WebEngineView.NewViewInWindow:
                    destination = NewViewRequest.NewViewInWindow;
                    break;
                case WebEngineView.NewViewInTab:
                    destination = NewViewRequest.NewViewInTab;
                    break;
                case WebEngineView.NewViewInDialog:
                    destination = NewViewRequest.NewViewInDialog;
                    break;
                case WebEngineView.NewViewInBackgroundTab:
                    destination = NewViewRequest.NewViewInBackgroundTab;
                    break;
            }
            pipe.newViewRequested(Requests.getNewViewRequest(webview, request, destination));
        }

        onCertificateError: {
            error.defer();
            var type = 0;
            switch(error.certError) {
                case error.SslPinnedKeyNotInCertificateChain:
                    type = CertificateError.BadIdentity;
                    break;
                case error.CertificateDateInvalid:
                    type = CertificateError.Expired;
                    break;
                case error.ErrorDateInvalid:
                    type = CertificateError.DateInvalid;
                    break;
                case error.CertificateAuthorityInvalid:
                    type = CertificateError.AuthorityInvalid;
                    break;
                case error.CertificateRevoked:
                    type = CertificateError.Revoked;
                    break;
                case error.CertificateInvalid:
                    type = CertificateError.Invalid;
                    break;
                case error.CertificateWeakKey:
                    type = CertificateError.Insecure;
                    break;
                case error.CertificateWeakSignatureAlgorithm:
                    type = CertificateError.Insecure;
                    break;
                default:
                    type = CertificateError.Generic;
            }
            pipe.certificateError(Errors.getCertificateError(webview, error, error.url, type, error.overridable));
        }

        onJavaScriptConsoleMessage: {
            var l = "";
            switch(level) {
                case WebEngineView.InfoMessageLevel:
                    l = MessageLevel.Info
                    break;
                case WebEngineView.WarningMessageLevel:
                    l = MessageLevel.Warning
                    break;
                case WebEngineView.ErrorMessageLevel:
                    l = MessageLevel.Error
                    break;
            }
            pipe.consoleMessage(l, message, lineNumber, sourceID)
        }

        onFeaturePermissionRequested: {
            var f;
            switch(feature) {
                case WebEngineView.Geolocation:
                    f = Feature.Location;
                    break;
                case WebEngineView.MediaAudioCapture:
                    f = Feature.AudioCapture;
                    break;
                case WebEngineView.MediaVideoCapture:
                    f = Feature.VideoCapture;
                    break;
                case WebEngineView.MediaAudioVideoCapture:
                    f = Feature.AudioVideoCapture;
                    break;
            }
            pipe.featureRequested(Requests.getFeatureRequest(webview, securityOrigin, f, feature));
        }

        function finishCreation() {
            webview.url = pipe ? pipe.url: Qt.resolvedUrl("");
            pipe.urlChanged.connect(function(){
                if (webview.url != pipe.url)
                    webview.url = pipe.url;
            });

            pipe.bind("url",            function(){ return webview.url          });
            pipe.bind("canGoBack",      function(){ return webview.canGoBack    });
            pipe.bind("canGoForward",   function(){ return webview.canGoForward });
            pipe.bind("icon",           function(){ return webview.icon         });
            pipe.bind("isFullScreen",   function(){ return webview.isFullScreen });
            pipe.bind("loadProgress",   function(){ return webview.loadProgress });
            pipe.bind("title",          function(){ return webview.title        });
            pipe.runJavaScript = function(script, callback){
                webview.runJavaScript(script, callback);
            }
            pipe.getHtml = function(callback){
                webview.runJavaScript("document.documentElement.innerHTML", callback);
            }
            pipe.setHtml = function(html, baseUrl){
                if (typeof baseUrl == 'undefined')
                    baseUrl = "";
                url = baseUrl;
                webview.loadHtml(html, baseUrl);
            }
            pipe.findText = function (text, backwards, caseSensitive, callback){
                var flags;
                if (backwards)
                    flags = WebEngineView.FindBackward
                if (caseSensitive)
                    flags |= WebEngineView.FindCaseSensitively
                webview.findText(text, flags, callback);
            };
            pipe.cancelFullScreen = webview.fullScreenCancelled;
            pipe.goBack = webview.goBack;
            pipe.goForward = webview.goForward;
            pipe.reload = webview.reload;
            pipe.stop = webview.stop;
            pipe.ready();
        }
    }
}
