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

    protected $fillable = ['id', 'user_id', 'title', 'message', 'is_read', 'action'];  // Thêm 'action' vào $fillable

    public static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->id)) {
                $latest = self::orderByDesc('id')->first();
                $nextIdNumber = 1;

                if ($latest && preg_match('/^NOTI(\d+)$/', $latest->id, $matches)) {
                    $nextIdNumber = (int)$matches[1] + 1;
                }

                // Sửa lỗi phép cộng giữa chuỗi và số
                $model->id = 'NOTI' . str_pad((string)$nextIdNumber, 3, '0', STR_PAD_LEFT);
            }

            // Đảm bảo action được điền vào (nếu không có giá trị, mặc định là 'appointment_deleted')
            if (empty($model->action)) {
                $model->action = 'appointment_deleted'; // Hoặc giá trị mặc định khác tùy nhu cầu
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'UserID');
    }

    // ✅ Xóa tất cả thông báo của một người dùng
    public static function clearAllNotifications($userId)
    {
        // Xóa tất cả thông báo của user_id
        self::where('user_id', $userId)->delete();
    }
}
