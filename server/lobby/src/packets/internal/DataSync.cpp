/**
 * @file server/lobby/src/packets/internal/DataSync.cpp
 * @ingroup lobby
 *
 * @author HACKfrost
 *
 * @brief Request from the world servers to synchronize one or more
 *  data records between the servers.
 *
 * This file is part of the Lobby Server (lobby).
 *
 * Copyright (C) 2012-2020 COMP_hack Team <compomega@tutanota.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Packets.h"

// libcomp Includes
#include <ManagerPacket.h>

// lobby Includes
#include "LobbyServer.h"
#include "LobbySyncManager.h"

using namespace lobby;

bool Parsers::DataSync::Parse(libcomp::ManagerPacket *pPacketManager,
    const std::shared_ptr<libcomp::TcpConnection>& connection,
    libcomp::ReadOnlyPacket& p) const
{
    (void)connection;

    auto server = std::dynamic_pointer_cast<LobbyServer>(pPacketManager->GetServer());
    auto syncManager = server->GetLobbySyncManager();

    if(!syncManager->SyncIncoming(p))
    {
        return false;
    }

    // Sync any records that need to relay back
    syncManager->SyncOutgoing();

    return true;
}
