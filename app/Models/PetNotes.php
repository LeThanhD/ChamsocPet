<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Pet;
use App\Models\User;
use App\Models\Service;
use Illuminate\Support\Str;


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
        'CreatedBy' // ✅ Bổ sung dòng này để fix lỗi Duplicate entry
    ];

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

    // Trong PetNotes.php (model)

    public static function generateUniqueNoteID()
{
    $lastNote = self::orderBy('NoteID', 'desc')->first();

    if ($lastNote) {
        $lastNumber = (int) substr($lastNote->NoteID, 5);
        $newNumber = $lastNumber + 1;
    } else {
        $newNumber = 1;
    }

    return 'PNOTE' . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
}

}
