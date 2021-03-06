/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.5
import QtWebEngine 1.2
import "../../components"
import "../utils"

EngineElement {
    engineName: "QtWebEngine"
    componentName: "WebProfile"

    property var profile: WebEngineProfile {
        offTheRecord: w.incognito
        storageName: "default"

        onDownloadRequested: {
            w.downloadRequested(Requests.getDownloadRequest(profile, download, downloadComponent, download.mimeType, engineName));
        }
    }

    Component {
        id: downloadComponent
        Download {}
    }
}
