<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Pet;
use App\Models\User;
use App\Models\Service;

class PetNotes extends Model
{
    use HasFactory;

    // Tên bảng trong cơ sở dữ liệu
    protected $table = 'PetNotes';

    // Khóa chính
    protected $primaryKey = 'NoteID';

    // Không tự động tăng khóa chính
    public $incrementing = false;
    protected $keyType = 'string'; 

    // Không sử dụng timestamps mặc định (created_at, updated_at)
    public $timestamps = false;

    // Các cột có thể ghi dữ liệu
    protected $fillable = [
        'NoteID',
        'PetID',
        'Content',
        'ServiceID',
        'CreatedAt'
    ];

    // Quan hệ: Mỗi ghi chú thuộc về 1 thú cưng
    public function pet()
    {
        return $this->belongsTo(Pet::class, 'PetID', 'PetID');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'CreatedBy', 'UserID');
    }

    public function service()
    {
        return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
    }
}
