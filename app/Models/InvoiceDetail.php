<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InvoiceDetail extends Model
{
    protected $table = 'InvoiceDetails';
    protected $primaryKey = 'DetailID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'InvoiceID',
        'ServiceID',
        'MedicationID',
        'Quantity',
        'UnitPrice'
    ];

    public function medication()
{
    return $this->belongsTo(Medications::class, 'MedicationID', 'MedicationID');
}

public function service()
{
    return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
}

    public function pet()
{
    return $this->belongsTo(Pet::class, 'PetID', 'PetID');
}

}
