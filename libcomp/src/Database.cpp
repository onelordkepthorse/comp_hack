/**
 * @file libcomp/src/Database.h
 * @ingroup libcomp
 *
 * @author COMP Omega <compomega@tutanota.com>
 *
 * @brief Base class to handle the database.
 *
 * This file is part of the COMP_hack Library (libcomp).
 *
 * Copyright (C) 2012-2016 COMP_hack Team <compomega@tutanota.com>
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

#include "Database.h"

using namespace libcomp;

Database::Database(const std::shared_ptr<objects::DatabaseConfig>& config)
{
    mConfig = config;
}

Database::~Database()
{
}

bool Database::Execute(const String& query)
{
    return Prepare(query).Execute();
}

String Database::GetLastError() const
{
    return mError;
}

std::shared_ptr<objects::DatabaseConfig> Database::GetConfig() const
{
    return mConfig;
}

bool Database::TableHasRows(const String& table)
{
    libcomp::DatabaseQuery query = Prepare(String(
        "SELECT COUNT(1) FROM %1").Arg(table.ToLower()));

    if(!query.IsValid())
    {
        return false;
    }

    if(!query.Execute())
    {
        return false;
    }

    if(!query.Next())
    {
        return false;
    }

    int64_t count;

    if(!query.GetValue(0, count))
    {
        return false;
    }

    return 0 < count;
}

std::shared_ptr<PersistentObject> Database::LoadSingleObject(size_t typeHash,
    DatabaseBind *pValue)
{
    auto objects = LoadObjects(typeHash, pValue);

    return objects.size() > 0 ? objects.front() : nullptr;
}

bool Database::DeleteSingleObject(std::shared_ptr<PersistentObject>& obj)
{
    std::list<std::shared_ptr<PersistentObject>> objs;
    objs.push_back(obj);
    return DeleteObjects(objs);
}

void Database::QueueInsert(std::shared_ptr<PersistentObject> obj,
    const libobjgen::UUID& uuid)
{
    auto s = DatabaseChangeSet::Create(uuid);
    s->Insert(obj);
    QueueChangeSet(s);
}

void Database::QueueUpdate(std::shared_ptr<PersistentObject> obj,
    const libobjgen::UUID& uuid)
{
    auto s = DatabaseChangeSet::Create(uuid);
    s->Update(obj);
    QueueChangeSet(s);
}

void Database::QueueDelete(std::shared_ptr<PersistentObject> obj,
    const libobjgen::UUID& uuid)
{
    auto s = DatabaseChangeSet::Create(uuid);
    s->Delete(obj);
    QueueChangeSet(s);
}

void Database::QueueChangeSet(const std::shared_ptr<
    DatabaseChangeSet>& changes)
{
    auto uuid = changes->GetTransactionUUID();
    std::string key = uuid.ToString();

    std::lock_guard<std::mutex> lock(mTransactionLock);
    auto queueEntry = mTransactionQueue[key];
    if(queueEntry == nullptr)
    {
        queueEntry = DatabaseChangeSet::Create(uuid);
    }

    for(auto obj : changes->GetInserts())
    {
        queueEntry->Insert(obj);
    }

    for(auto obj : changes->GetUpdates())
    {
        queueEntry->Update(obj);
    }

    for(auto obj : changes->GetDeletes())
    {
        queueEntry->Delete(obj);
    }

    mTransactionQueue[key] = queueEntry;
}

std::list<libobjgen::UUID> Database::ProcessTransactionQueue()
{
    std::list<libobjgen::UUID> failures;

    std::unordered_map<std::string,
        std::shared_ptr<DatabaseChangeSet>> queue;
    {
        std::lock_guard<std::mutex> lock(mTransactionLock);

        if(mTransactionQueue.size() == 0)
        {
            return failures;
        }

        queue = mTransactionQueue;
        mTransactionQueue.clear();
    }

    // Process the general queue transaction first
    auto nullKey = NULLUUID.ToString();
    if(queue.find(nullKey) != queue.end())
    {
        if(!ProcessChangeSet(queue[nullKey]))
        {
            failures.push_back(nullKey);
        }
        queue.erase(nullKey);
    }

    // Process the remaining transactions
    for(auto kv : queue)
    {
        if(!ProcessChangeSet(kv.second))
        {
            failures.push_back(kv.second->GetTransactionUUID());
        }
    }

    return failures;
}

std::shared_ptr<PersistentObject> Database::LoadSingleObjectFromRow(
    size_t typeHash, DatabaseQuery& query)
{
    bool isNew = false;

    std::shared_ptr<PersistentObject> obj;

    libobjgen::UUID uid;
    if(query.GetValue("UID", uid))
    {
        //If the object is already cached, refresh it
        obj = PersistentObject::GetObjectByUUID(uid);
    }

    if(nullptr == obj)
    {
        obj = PersistentObject::New(typeHash);
        isNew = true;
    }

    if(!obj->LoadDatabaseValues(query))
    {
        return nullptr;
    }

    if(isNew)
    {
        PersistentObject::Register(obj);
    }

    return obj;
}
