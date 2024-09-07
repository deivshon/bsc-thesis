import SQLiteDatabase from "better-sqlite3";
import { Kysely, SqliteDialect } from "kysely";
import { Todo, TodoCreate, todoSchema, TodoUpdate } from "../../models/todo";

type Database = {
    todos: Omit<Todo, "done"> & {
        done: number;
    };
};

const db = new Kysely<Database>({
    dialect: new SqliteDialect({
        database: new SQLiteDatabase("todo.db.sqlite3"),
    }),
});

const withBoolean = <T extends NonNullable<Record<string, unknown>>>(
    obj: T,
    keys: Array<keyof T>,
) => {
    const newObj: { [key in (typeof keys)[number]]: unknown } = { ...obj };

    keys.forEach((key) => {
        newObj[key] = Boolean(newObj[key]);
    });

    return newObj;
};

class TodoStorage {
    constructor() {
        this.initialize();
    }

    private async initialize() {
        await db.schema
            .createTable("todos")
            .ifNotExists()
            .addColumn("id", "text", (col) => col.primaryKey())
            .addColumn("content", "text", (col) => col.notNull())
            .addColumn("createdAt", "integer", (col) => col.notNull())
            .addColumn("updatedAt", "integer", (col) => col.notNull())
            .addColumn("done", "integer", (col) => col.notNull())
            .execute();
    }

    public create = async (todo: TodoCreate): Promise<Todo> => {
        const id = crypto.randomUUID();
        const now = Date.now();

        const newTodoModel = {
            id,
            content: todo.content,
            createdAt: now,
            updatedAt: now,
            done: 0,
        };

        await db.insertInto("todos").values(newTodoModel).execute();

        return this.toTodo(newTodoModel);
    };

    public readAll = async (): Promise<Todo[]> => {
        const rows = await db.selectFrom("todos").selectAll().execute();
        return rows.map(this.toTodo);
    };

    public readOne = async (id: string): Promise<Todo | null> => {
        const row = await db
            .selectFrom("todos")
            .selectAll()
            .where("id", "=", id)
            .executeTakeFirst();

        if (!row) return null;

        return this.toTodo(row);
    };

    async update(id: string, updatedTodo: TodoUpdate): Promise<void> {
        const existingTodo = await this.readOne(id);
        if (!existingTodo) {
            throw new Error(`Todo with id ${id} does not exist`);
        }

        const todo = { ...existingTodo, ...updatedTodo, updatedAt: Date.now() };

        await db
            .updateTable("todos")
            .set({
                content: todo.content,
                updatedAt: todo.updatedAt,
                done: todo.done ? 1 : 0,
            })
            .where("id", "=", id)
            .execute();
    }

    async delete(id: string): Promise<void> {
        await db.deleteFrom("todos").where("id", "=", id).execute();
    }

    private toTodo = (row: Database["todos"]): Todo => {
        return todoSchema.parse(withBoolean(row, ["done"]));
    };
}

export const todoStorage = new TodoStorage();
