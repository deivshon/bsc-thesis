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

        const userModel: UserDbModel = {
            id,
            username: newUser.username,
            password: newUser.password,
            createdAt: now,
        };

        const existingUser = await db
            .selectFrom("users")
            .selectAll()
            .where("username", "=", newUser.username)
            .executeTakeFirst();
        if (existingUser) {
            throw new Error("User already exists");
        }

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

        if (!user) throw new Error("User not found");

        if (user.password !== password) throw new Error("Invalid password");

        return this.toUser(user);
    };

    public async userExists(userId: string) {
        const user = await db
            .selectFrom("users")
            .selectAll()
            .where("id", "=", userId)
            .executeTakeFirst();

        return Boolean(user);
    }

    private toUser = (dbModel: UserDbModel): User => {
        const { password, ...user } = dbModel;
        return user;
    };
}

export const userStorage = new UserStorage();
