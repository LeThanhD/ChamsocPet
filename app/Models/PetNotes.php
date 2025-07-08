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

    // Thêm dòng này:
    const CREATED_AT = 'CreatedAt';

    protected $fillable = [
        'NoteID',
        'PetID',
        'Content',
        'ServiceID',
        'CreatedAt'
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
}

