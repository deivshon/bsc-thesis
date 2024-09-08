import bcrypt from "bcrypt";
import { sql } from "kysely";
import { User, UserCreate, UserDbModel } from "../../models/user";
import { db } from "./db";

const SALT_ROUNDS = 10;

export class UserStorage {
    constructor() {
        this.initialize();
    }

    private async initialize() {
        await db.schema
            .createTable("users")
            .ifNotExists()
            .addColumn("id", "text", (col) => col.primaryKey())
            .addColumn("username", "text", (col) => col.notNull().unique())
            .addColumn("password", "text", (col) => col.notNull())
            .addColumn("createdAt", "integer", (col) => col.notNull())
            .execute();
    }

    public createUser = async (newUser: UserCreate): Promise<User> => {
        const id = crypto.randomUUID();
        const now = Date.now();
        const passwordHash = await bcrypt.hash(newUser.password, SALT_ROUNDS);

        const userModel: UserDbModel = {
            id,
            username: newUser.username,
            password: passwordHash,
            createdAt: now,
        };

        await db.insertInto("users").values(userModel).execute();

        return this.toUser(userModel);
    };

    public readUser = async (userId: string): Promise<User | null> => {
        const user = await db
            .selectFrom("users")
            .selectAll()
            .where("id", "=", userId)
            .executeTakeFirst();

        return user ? this.toUser(user) : null;
    };

    public searchUsers = async (query: string): Promise<Array<User>> => {
        const users = await db
            .selectFrom("users")
            .selectAll()
            .select(() => [
                sql<number>`instr(username, ${query})`.as("relevance"),
            ])
            .where("username", "like", `%${query}%`)
            .orderBy("relevance", "desc")
            .orderBy("username", "asc")
            .execute();

        return users.map((user) => this.toUser(user));
    };

    public login = async (
        username: string,
        password: string,
    ): Promise<User | null> => {
        const user = await db
            .selectFrom("users")
            .selectAll()
            .where("username", "=", username)
            .executeTakeFirst();

        if (!user) return null;

        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) return null;

        return this.toUser(user);
    };

    private toUser = (dbModel: UserDbModel): User => {
        const { password, ...user } = dbModel;
        return user;
    };
}

export const userStorage = new UserStorage();
