import { Post, PostCreate, PostDbModel, postSchema } from "../../models/post";
import { db } from "./db";
import { userStorage } from "./user.storage";

export class PostStorage {
    constructor() {
        this.initialize();
    }

    private async initialize() {
        await db.schema
            .createTable("posts")
            .ifNotExists()
            .addColumn("id", "text", (col) => col.primaryKey())
            .addColumn("content", "text", (col) => col.notNull())
            .addColumn("userId", "text", (col) => col.notNull())
            .addColumn("createdAt", "integer", (col) => col.notNull())
            .addColumn("likes", "integer", (col) => col.notNull().defaultTo(0))
            .execute();
    }

    public createPost = async (
        newPost: PostCreate,
        userId: string,
    ): Promise<Post> => {
        const id = crypto.randomUUID();
        const now = Date.now();

        const postModel: PostDbModel = {
            id,
            content: newPost.content,
            userId: userId,
            createdAt: now,
            likes: 0,
        };

        const user = await userStorage.readUser(userId);
        if (!user) {
            throw new Error("User creating the post not found");
        }
        await db.insertInto("posts").values(postModel).execute();

        return this.toPost(
            {
                ...postModel,
                username: user.username,
            },
            false,
        );
    };

    public readPost = async (
        postId: string,
        userId: string,
    ): Promise<Post | null> => {
        const post = await db
            .selectFrom("posts")
            .leftJoin("likes", (join) =>
                join
                    .onRef("likes.postId", "=", "posts.id")
                    .on("likes.userId", "=", userId || null),
            )
            .innerJoin("users", "users.id", "posts.userId")
            .select([
                "posts.id",
                "posts.content",
                "posts.userId",
                "posts.createdAt",
                "posts.likes",
                "users.username",
                db.fn.count("likes.userId").as("likedByUser"),
            ])
            .where("posts.id", "=", postId)
            .groupBy("posts.id")
            .executeTakeFirst();

        return post ? this.toPost(post, Boolean(post.likedByUser)) : null;
    };

    public readPaginatedPosts = async (
        skip: number,
        limit: number,
        userId: string,
        targetUserId?: string,
    ): Promise<Post[]> => {
        let query = db
            .selectFrom("posts")
            .leftJoin("likes", (join) =>
                join
                    .onRef("likes.postId", "=", "posts.id")
                    .on("likes.userId", "=", userId || null),
            )
            .innerJoin("users", "users.id", "posts.userId")
            .select([
                "posts.id",
                "posts.content",
                "posts.userId",
                "posts.createdAt",
                "posts.likes",
                "users.username",
                db.fn.count("likes.userId").as("likedByUser"),
            ]);

        if (targetUserId) {
            query = query.where("posts.userId", "=", targetUserId);
        }

        const posts = await query
            .groupBy("posts.id")
            .orderBy("posts.createdAt", "desc")
            .limit(limit)
            .offset(skip)
            .execute();

        return posts.map((post) =>
            this.toPost(post, Boolean(post.likedByUser)),
        );
    };

    public updatePostLikes = async (
        postId: string,
        likes: number,
    ): Promise<void> => {
        await db
            .updateTable("posts")
            .set({ likes })
            .where("id", "=", postId)
            .execute();
    };

    private toPost = (
        dbModel: PostDbModel & {
            likedByUser?: number | bigint | string;
            username: string;
        },
        likedByUser: boolean,
    ): Post => {
        const post = {
            ...dbModel,
            likedByUser,
        };

        return postSchema.parse(post);
    };
}

export const postStorage = new PostStorage();
