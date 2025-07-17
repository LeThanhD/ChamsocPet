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

    protected $table = 'PetNotes';
    protected $primaryKey = 'NoteID';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'NoteID',
        'PetID',
        'Content',
        'ServiceID',
        'CreatedAt',
        'CreatedBy',
    ];

    // 🔗 Quan hệ
    public function pet()
    {
        return $this->belongsTo(Pet::class, 'PetID', 'PetID');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'CreatedBy', 'UserID');
    }

    public function latest_note()
    {
        return $this->hasOne(PetNotes::class, 'PetID', 'PetID')->latestOfMany();
    }

    public function service()
    {
        return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
    }

    // ✅ Tạo NoteID duy nhất
    public static function generateUniqueNoteID()
    {
        $prefix = 'PNOTE';
        $latest = self::orderBy('NoteID', 'desc')->first();
        $number = $latest ? intval(substr($latest->NoteID, strlen($prefix))) : 0;

        do {
            $number++;
            $newID = $prefix . str_pad($number, 4, '0', STR_PAD_LEFT);
        } while (self::where('NoteID', $newID)->exists()); // 🔒 Kiểm tra trùng thực tế

        return $newID;
    }
}
