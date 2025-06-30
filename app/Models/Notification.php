<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Notification extends Model
{
    protected $table = 'notifications';

    // ❌ Vô hiệu hóa timestamps mặc định của Laravel
    public $timestamps = false;

    // ❗ Khóa chính không tự tăng
    public $incrementing = false;

    // ❗ Khóa chính kiểu string
    protected $keyType = 'string';

    // ✅ Cho phép gán hàng loạt
    protected $fillable = [
        'id',
        'user_id',
        'title',
        'message',
        'is_read',
        'created_at',
    ];

    // ✅ Tự sinh UUID nếu chưa có ID
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }
}
