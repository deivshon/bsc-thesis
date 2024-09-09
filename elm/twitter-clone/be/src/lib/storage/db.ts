import SQLiteDatabase from "better-sqlite3";
import { Kysely, SqliteDialect } from "kysely";
import { LikeDbModel } from "../../models/like";
import { PostDbModel } from "../../models/post";
import { UserDbModel } from "../../models/user";

type Database = {
    likes: LikeDbModel;
    posts: PostDbModel;
    users: UserDbModel;
};

export const db = new Kysely<Database>({
    dialect: new SqliteDialect({
        database: new SQLiteDatabase("twitter-clone.db.sqlite3"),
    }),
});
