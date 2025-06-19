<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PetNotes extends Model
{
    protected $table = 'petnotes';
    protected $primaryKey = 'NoteID';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'NoteID',
        'PetID',
        'CreatedBy',
        'CreatedAt',
        'Content',
        'ServiceID',
    ];

    public $timestamps = false;

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
