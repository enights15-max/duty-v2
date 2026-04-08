<?php

namespace App\Traits;

use App\Models\Follow;

trait Followable
{
    /**
     * Get all follows where this model is the one following another entity.
     */
    public function follows()
    {
        return $this->morphMany(Follow::class, 'follower');
    }

    /**
     * Get all follows where this model is the one being followed by another entity.
     */
    public function followers()
    {
        return $this->morphMany(Follow::class, 'followable');
    }

    /**
     * Helper to check if this model is following another model.
     */
    public function isFollowing($model)
    {
        return $this->follows()
            ->where('followable_id', $model->id)
            ->where('followable_type', get_class($model))
            ->where('status', 'accepted')
            ->exists();
    }

    /**
     * Helper to check if this model has a pending follow request to another model.
     */
    public function hasPendingFollowRequest($model)
    {
        return $this->follows()
            ->where('followable_id', $model->id)
            ->where('followable_type', get_class($model))
            ->where('status', 'pending')
            ->exists();
    }
}
