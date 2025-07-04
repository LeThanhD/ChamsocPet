<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;


class Notification extends Model
{
    protected $table = 'notifications';
    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false; // ✅ Tắt updated_at và created_at

    protected $fillable = ['id', 'user_id', 'title', 'message', 'is_read'];

    public static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $latest = self::orderByDesc('id')->first();
                $nextNumber = 1;

                if ($latest && preg_match('/^NOTI(\d+)$/', $latest->id, $matches)) {
                    $nextNumber = intval($matches[1]) + 1;
                }

                $model->id = 'NOTI' . str_pad($nextNumber, 3, '0', STR_PAD_LEFT);
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'UserID');
    }
}
