import { LikeDbModel } from "../../models/like";
import { db } from "./db";
import { postStorage, PostStorage } from "./post.storage";

export class LikeStorage {
    constructor(private readonly postStorage: PostStorage) {
        this.initialize();
    }

    private async initialize() {
        await db.schema
            .createTable("likes")
            .ifNotExists()
            .addColumn("postId", "text", (col) => col.notNull())
            .addColumn("userId", "text", (col) => col.notNull())
            .addColumn("createdAt", "integer", (col) => col.notNull())
            .addPrimaryKeyConstraint("likes_primary_key", ["postId", "userId"])
            .execute();
    }

    public createLike = async (
        postId: string,
        userId: string,
    ): Promise<void> => {
        const existingLike = await db
            .selectFrom("likes")
            .selectAll()
            .where("postId", "=", postId)
            .where("userId", "=", userId)
            .executeTakeFirst();

        if (existingLike) {
            throw new Error("Like already exists");
        }

        const now = Date.now();
        const likeModel: LikeDbModel = {
            postId,
            userId,
            createdAt: now,
        };
        await db.insertInto("likes").values(likeModel).execute();
        await this.updateLikeCount(postId, "added", userId);
    };

    public deleteLike = async (
        postId: string,
        userId: string,
    ): Promise<void> => {
        const existingLike = await db
            .selectFrom("likes")
            .selectAll()
            .where("postId", "=", postId)
            .where("userId", "=", userId)
            .executeTakeFirst();

        if (!existingLike) {
            return;
        }

        await db
            .deleteFrom("likes")
            .where("postId", "=", postId)
            .where("userId", "=", userId)
            .execute();
        await this.updateLikeCount(postId, "removed", userId);
    };

    private updateLikeCount = async (
        postId: string,
        like: "removed" | "added",
        userId: string,
    ) => {
        const post = await this.postStorage.readPost(postId, userId);
        if (!post) {
            throw new Error(`Post with id ${postId} not found`);
        }

        const updatedLikes = like === "added" ? post.likes + 1 : post.likes - 1;

        await this.postStorage.updatePostLikes(postId, updatedLikes);
    };
}

export const likeStorage = new LikeStorage(postStorage);
